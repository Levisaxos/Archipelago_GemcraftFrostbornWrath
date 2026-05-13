package patch {
    import Bezel.Logger;
    import com.giab.games.gcfw.GV;
    import flash.display.Bitmap;
    import flash.text.TextField;

    import unlockers.AchievementUnlocker;

    /**
     * Rebuilds the McInfoPanel breakdown for the "skill points left" hover
     * tooltip on the Skills panel so it reflects the AP economy:
     *
     *   Vanilla shows                       We show
     *   ------------------------------      ------------------------------
     *   Wizard level N base value: X    ←   (unchanged)
     *   Trial mode reward: +Y           →   Skillpoint bundles: +bundles
     *   Achievements: +Z (all gained)   →   Achievements: +excluded-only
     *
     * The vanilla total = level + vAchiSkillPtBonus + skillPtsFromLoot.
     * After AchievementUnlocker.reconcileSkillPoints sets
     *   skillPtsFromLoot = bundles − ap-tracked-achievement-sp
     * the formula collapses to (level + excluded + bundles), which matches
     * the breakdown we render. The "Total skill points" line is left at the
     * vanilla value — it's already correct.
     *
     * Tooltip is identified by its first textfield starting with
     * "Total skill points:", a string unique to this hover. When AP isn't
     * active, AchievementUnlocker.getSkillPointBreakdown returns null and
     * we leave the vanilla tooltip alone.
     *
     * Implementation: McInfoPanel.separatorYs is private, so we can't
     * splice the existing layout — instead we call reset() and rebuild
     * the whole panel via the public addTextfield/addSeparator API,
     * mirroring PnlSkills.renderInfoPanelSkillPtsLeft.
     */
    public class SkillsTooltipOverlay {

        private var _logger:Logger;
        private var _modName:String;
        private var _achievementUnlocker:AchievementUnlocker;

        // True after we've rebuilt the current tooltip. Cleared when
        // isImageRendered goes false (panel closed or new hover).
        private var _rebuilt:Boolean = false;

        // -----------------------------------------------------------------------

        public function SkillsTooltipOverlay(logger:Logger, modName:String,
                                             achievementUnlocker:AchievementUnlocker) {
            _logger              = logger;
            _modName             = modName;
            _achievementUnlocker = achievementUnlocker;
        }

        // -----------------------------------------------------------------------

        /** Called every selector frame from ArchipelagoMod.onSelectorFrame(). */
        public function onSelectorFrame():void {
            if (GV.mcInfoPanel == null) return;
            var vIp:* = GV.mcInfoPanel;

            if (vIp.parent == null || !vIp.isImageRendered) {
                _rebuilt = false;
                return;
            }
            if (_rebuilt) return;

            var textfields:Array = vIp.textfields as Array;
            if (textfields == null || textfields.length == 0) return;

            var firstTf:TextField = textfields[0] as TextField;
            if (firstTf == null || firstTf.text == null) return;
            if (firstTf.text.indexOf("Total skill points:") != 0) return;

            var breakdown:Object = _achievementUnlocker.getSkillPointBreakdown();
            if (breakdown == null) {
                _rebuilt = true;  // leave vanilla untouched
                return;
            }

            try {
                _rebuild(vIp,
                        int(breakdown.bundles),
                        int(breakdown.achievementsExcluded));
            } catch (err:Error) {
                _logger.log(_modName, "SkillsTooltipOverlay rebuild error: " + err.message);
                _rebuilt = true;
                return;
            }

            _rebuilt = true;
        }

        // -----------------------------------------------------------------------

        /**
         * Mirror PnlSkills.renderInfoPanelSkillPtsLeft, substituting our
         * breakdown lines for the vanilla Trial/Achievements ones. Colors
         * and addTextfield arg shape are copied from the vanilla call sites
         * so the visual output is indistinguishable.
         */
        private function _rebuild(vIp:*, bundles:int, excludedAchi:int):void {
            if (GV.ppd == null) return;

            // Numbers we need for the rebuild. Total is computed the same
            // way vanilla does so it remains consistent.
            var vLevel:Number = GV.ppd.getWizLevel();
            var vSkillPtsBought:int = GV.ppd.skillPtsBought.g();
            var vAchiResetSkillPtBonus:int = GV.ppd.achiResetSkillPtBonus.g();
            var vLevelSkillPts:Number = (vLevel + 1) * GV.skillPtsByWizLevel.g();

            // Vanilla "Achievements" total used in the displayed grand total.
            // Reading this back ensures the header value matches what the
            // unmodified tooltip would have shown.
            var vAchiSkillPtBonus:int = 0;
            try {
                vAchiSkillPtBonus = int(GV.selectorCore.pnlAchievements.calculateSkillPtBonus());
            } catch (e:Error) {
                // Fallback: ap-tracked + excluded equals the full sum.
                var bd:Object = _achievementUnlocker.getSkillPointBreakdown();
                if (bd != null) {
                    vAchiSkillPtBonus = int(bd.achievementsAp) + int(bd.achievementsExcluded);
                }
            }
            var vSkillPtsFromLoot:int = GV.ppd.skillPtsFromLoot.g();
            var vTotal:Number = vSkillPtsBought + vAchiResetSkillPtBonus
                              + vLevelSkillPts + vAchiSkillPtBonus + vSkillPtsFromLoot;

            // Dispose the vanilla bitmap before reset; reset() also nulls bmp
            // but explicit dispose makes ownership clear.
            try {
                var oldBmp:Bitmap = vIp.bmp as Bitmap;
                if (oldBmp != null && oldBmp.bitmapData != null) {
                    oldBmp.bitmapData.dispose();
                }
            } catch (eb:Error) {}

            // Undo the projectorZoom multiplication that drawBitmap baked
            // into vIp.w in the first render so reset()'s width math is
            // correct. reset() pulls the new w from its pPlateWidth arg
            // anyway, so this is belt-and-suspenders.
            try {
                var zoom:Number = Number(GV.projectorZoom);
                if (zoom > 0) vIp.w = vIp.w / zoom;
            } catch (ez:Error) {}

            // Restart layout. PnlSkills passes 420 — match it.
            vIp.reset(420);

            // Total line (color/size/leading copied verbatim from vanilla
            // PnlSkills.renderInfoPanelSkillPtsLeft).
            vIp.addTextfield(16777215,
                    "Total skill points: " + _fmt(vTotal),
                    false, 13);

            // Wizard level base value.
            vIp.addTextfield(14077111,
                    "Wizard level " + _fmt(vLevel + 1) + " base value: " + _fmt(vLevelSkillPts),
                    true, 12, null, 16777215);

            // Our breakdown lines replace the vanilla Trial/Achievements
            // lines. Order matches vanilla flow (achievements first, then
            // the loot-style line).
            if (excludedAchi > 0) {
                vIp.addTextfield(15656363,
                        "Achievements: +" + _fmt(excludedAchi),
                        true, 12, null, 16777215);
            }
            if (bundles > 0) {
                vIp.addTextfield(57248,
                        "Skillpoint bundles: +" + _fmt(bundles),
                        true, 12, null, 16777215);
            }

            // Preserve the vanilla Resetting-achievements and Shadow-core-
            // bought lines if they apply — we don't touch their economy.
            if (vAchiResetSkillPtBonus > 0) {
                vIp.addTextfield(15663019,
                        "Resetting achievements: +" + _fmt(vAchiResetSkillPtBonus),
                        true, 12, null, 16777215);
            }
            if (vSkillPtsBought > 0) {
                vIp.addTextfield(16699272,
                        "Bought with shadow cores: +" + _fmt(vSkillPtsBought),
                        true, 12, null, 16777215);
            }

            vIp.addExtraHeight(12 + 12);
            vIp.addSeparator(-6);
            vIp.addTextfield(14077111,
                    "Every unspent skill point gives " + GV.manaForUnspentSkillPoints.g() + " initial mana",
                    true, 12, null, 7663103);
            vIp.addExtraHeight(12);

            // doEnterFrame builds the bitmap and adds children. The panel
            // is still parented to cntInfoPanel from the vanilla call.
            try {
                vIp.doEnterFrame();
            } catch (e:Error) {
                _logger.log(_modName, "SkillsTooltipOverlay doEnterFrame error: " + e.message);
            }
        }

        // -----------------------------------------------------------------------

        /** Match vanilla's NumberFormatter output for integer values: thousands
         *  separator only when ≥ 1000. Keeps the rebuild visually identical to
         *  the original tooltip for the same total. */
        private function _fmt(n:Number):String {
            var v:int = int(n);
            var negative:Boolean = v < 0;
            var abs:int = negative ? -v : v;
            var s:String = String(abs);
            if (abs >= 1000) {
                var withCommas:String = "";
                var len:int = s.length;
                for (var i:int = 0; i < len; i++) {
                    if (i > 0 && (len - i) % 3 == 0) withCommas += ",";
                    withCommas += s.charAt(i);
                }
                s = withCommas;
            }
            return negative ? "-" + s : s;
        }
    }
}
