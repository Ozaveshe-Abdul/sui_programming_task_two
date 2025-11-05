/*
/// Module: task_two
module task_two::task_two;
*/

// For Move coding conventions, see
// https://docs.sui.io/concepts/sui-move-concepts/conventions

/*
Unit Two Task: Transcript Object (Guidance-Only File)
Purpose
- This task builds on Unit One (Student Object) by introducing a Transcript system.
- You will create, manage, and securely transfer student transcripts using Sui Move.
- Follow the TODO sections to implement the required functionality.

References
- Review Unit One (Student Object) for struct and function patterns.
- Lessons directory: lessons/

----------------------------------------
TODO 1: Module Declaration
----------------------------------------
- Declare the module at the top of the file.
- Use the same package name as Unit One, but update the module name to reflect transcripts.
- Example: `module sui_intro_unit_two::transcript`

----------------------------------------
TODO 2: Imports
----------------------------------------
- Import only what is necessary:
  - `sui::event` for emitting events.
  - `sui::transfer` for object transfers.
  - `sui::object` for object creation.
- Avoid unused imports.

----------------------------------------
TODO 3: Define the Transcript Struct
----------------------------------------
- Create a `Transcript` struct with the following fields:
  - `id: UID` (for global storage).
  - `student_id: ID` (link to the Student object from Unit One).
  - `history: u8` (grade for history).
  - `math: u8` (grade for math).
  - `literature: u8` (grade for literature).
- Assign appropriate abilities (`key`, `store`).

----------------------------------------
TODO 4: Define the WrappedTranscript Struct
----------------------------------------
- Create a `WrappedTranscript` struct to securely transfer transcripts:
  - `id: UID`.
  - `transcript: Transcript`.
  - `intended_address: address` (recipient address).
- Assign appropriate abilities (`key`).

----------------------------------------
TODO 5: Define the TeacherCap Struct
----------------------------------------
- Create a `TeacherCap` struct to manage teacher privileges:
  - `id: UID`.
- Assign appropriate abilities (`key`).

----------------------------------------
TODO 6: Module Initialization
----------------------------------------
- Write an `init` function to issue a `TeacherCap` to the module publisher.
- This function should only be called once, during module publication.

----------------------------------------
TODO 7: TeacherCap Management
----------------------------------------
- Implement `add_teacher`:
  - Only callable by a `TeacherCap` holder.
  - Issues a new `TeacherCap` to a specified address.

----------------------------------------
TODO 8: Transcript Creation
----------------------------------------
- Implement `create_transcript`:
  - Only callable by a `TeacherCap` holder.
  - Takes `student_id`, `history`, `math`, and `literature` as arguments.
  - Creates a `Transcript` and transfers it to the teacher.

----------------------------------------
TODO 9: Transcript Operations
----------------------------------------
- Implement the following functions:
  - `view_grade`: Read-only access to a specific grade.
  - `update_grade`: Update a grade (requires `TeacherCap`).
  - `delete_transcript`: Delete a transcript (requires `TeacherCap`).

----------------------------------------
TODO 10: Secure Transcript Transfer
----------------------------------------
- Implement `wrap_transcript`:
  - Wraps a `Transcript` in a `WrappedTranscript` for secure transfer.
  - Emits a `TranscriptRequestEvent` to log the transfer.
  - Transfers the `WrappedTranscript` to the intended recipient.
- Implement `unpack_transcript`:
  - Only the intended recipient can unpack the `WrappedTranscript`.
  - Transfers the `Transcript` to the recipient.

----------------------------------------
TODO 11: Events
----------------------------------------
- Define a `TranscriptRequestEvent` struct to log transcript requests:
  - `transcript_id: ID`.
  - `requester: address`.
  - `intended_address: address`.
- Emit this event in `wrap_transcript`.

----------------------------------------
Stretch Goals (Optional)
----------------------------------------
- Add a function to view all grades at once.
- Implement batch grade updates.
- Add metadata (e.g., student name, date) to the transcript.
- Extend the system to support multiple teachers and students.

----------------------------------------
Checklist
----------------------------------------
- Build the package: `sui move build`.
- Publish the package: `sui client publish /path/to/package`.
- Test all functions:
  - Mint a `TeacherCap`.
  - Create, update, and delete transcripts.
  - Wrap and unpack transcripts.
- Verify events and object transfers in the explorer.

----------------------------------------
CLI Reminders
----------------------------------------
- Build: `sui move build`
- Publish: `sui client publish --gas-budget 10000 /path/to/package`
- Call functions with typed arguments:
  - Example: `sui client call --function create_transcript --module transcript --package <PACKAGE_ID> --args <TEACHER_CAP_ID> <STUDENT_ID> 90 85 95 --gas-budget 10000`

----------------------------------------
Troubleshooting Tips
----------------------------------------
- Ensure all structs have the correct abilities.
- Verify access control for mutable operations.
- Check event emission and object transfers.
- Confirm CLI arguments match function parameters.
*/

