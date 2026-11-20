from test.bases import WorldTestBase

from .. import GemcraftFrostbornWrathWorld


class GCFWTestBase(WorldTestBase):
    """Base for every GCFW test. Subclasses that set `options` also get WorldTestBase's three default tests (all-state reachability + beatable, empty-state can reach something, full fill + accessibility) for that option preset."""
    game = "GemCraft: Frostborn Wrath"
    world: GemcraftFrostbornWrathWorld
