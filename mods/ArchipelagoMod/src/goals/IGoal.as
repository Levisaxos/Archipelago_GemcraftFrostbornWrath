package goals {

    /**
     * Interface for goal detection strategies.
     * Each implementation checks a specific win condition
     * and returns a display name for the toast message.
     */
    public interface IGoal {

        /** Returns true if the goal condition is currently met. */
        function check():Boolean;

        /** Human-readable name shown in the completion toast. */
        function get goalName():String;
    }
}
