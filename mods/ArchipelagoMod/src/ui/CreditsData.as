package ui {
    public class CreditsData {
        
        public static function getSections():Array
        {
            return [
                {
                    sectionTitle: "Testers",
                    lines: [
                        "Thank you to everyone who tested, broke things, and reported bugs:",
                        "",
                        "    •  Xindage",
                        "    •  Klatski",
                        "    •  The White Lily Cookie Fanclub",
                        "    •  Boo",
                        "    •  Ne01nvAdeR [TPT2], ",
                        "    •  snekk"
                    ]
                },
                {
                    sectionTitle: "Game Developers",
                    lines: [
                        "GemCraft: Frostborn Wrath by Game in a Bottle.",
                        "This is a fan project, not affiliated with or endorsed by Game in a Bottle."
                    ]
                },
                {
                    sectionTitle: "Archipelago & Tooling",
                    lines: [
                        "Archipelago — the multiworld randomizer framework.",
                        "BezelModLoader — the GemCraft: Frostborn Wrath mod loader."
                    ]
                },
                {
                    sectionTitle: "Special Thanks",
                    lines: [
                        "Built by Levisaxos.",
                        "Snekk    (github.com/flower-snek) - For help in early logic development",
                        "Xindage  (github.com/Xindage) - For testing",
                        "Klatsi   (https://github.com/Klaty) - For testing",
                        "",
                        "...and everyone in the community who made this possible."
                    ]
                }
            ];
        }
    }
}
