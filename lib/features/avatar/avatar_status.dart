/// ------------------------------------------------------------
/// Avatar Status
/// Represents the current interaction state of the avatar
/// ------------------------------------------------------------
enum AvatarStatus {
  /// No active interaction
  idle,

  /// Microphone is active, waiting for input
  listening,

  /// User speech is currently being detected
  hearing,

  /// Processing user input
  thinking,

  /// Responding to the user via speech
  speaking,

  /// An unrecoverable or unexpected error state
  error,
}