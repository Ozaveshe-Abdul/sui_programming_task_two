# Task Two: Transcript Management System

## Project Overview

This project is part of a Sui Move programming course designed to teach students how to build secure, object-oriented smart contracts on the Sui blockchain. Task Two focuses on creating a **Transcript Management System** that demonstrates key Move concepts including:

- **Object abilities** (`key`, `store`, `drop`, `copy`)
- **Access control** using capability objects
- **Secure object wrapping and unwrapping**
- **Event emission** for tracking transactions
- **Ownership and transfer** patterns

In this task, you will build a system where teachers can create, update, and manage student transcripts, while implementing secure transfer mechanisms that ensure only intended recipients can access transcript data.

## Learning Objectives

By completing this task, you will learn:

1. **Struct Design**: How to design Move structs with appropriate abilities
2. **Capability Pattern**: Using capability objects (`TeacherCap`) to control access
3. **Object Wrapping**: Securely wrapping objects for transfer with access control
4. **Event System**: Emitting events to track important transactions
5. **Module Initialization**: Setting up modules with initial state
6. **Access Control**: Implementing different permission levels (view, update, delete)

## Prerequisites

- Completion of **Unit One** (Student Object) or equivalent Move knowledge
- Basic understanding of Sui Move concepts:
  - Structs and abilities
  - Functions and visibility
  - Object ownership
  - Transfer patterns
- Sui CLI installed and configured
- A local Sui development environment set up

## Project Structure

```
task_two/
├── Move.toml          # Package configuration
├── sources/
│   └── task_two.move  # Main module file (contains TODO comments)
├── tests/
│   └── task_two_tests.move  # Test file
└── README.md          # This file
```

## Task Requirements

### TODO 1: Module Declaration

**Objective**: Declare the module at the top of the file.

**Instructions**:
- Use the module name `task_two::task_two` (or update if using a different package name)
- Add the module declaration after any copyright/license headers

**Example**:
```move
module task_two::task_two;
```

---

### TODO 2: Imports

**Objective**: Import only the necessary Sui framework modules.

**Instructions**:
- Import `sui::event` for emitting events
- Import `sui::transfer` for object transfers
- Import `sui::object` for object creation and UID management
- Import `sui::tx_context` for transaction context

**Example**:
```move
use sui::event;
use sui::transfer;
use sui::object::{Self, UID, ID};
use sui::tx_context::{Self, TxContext};
```

---

### TODO 3: Define the Transcript Struct

**Objective**: Create a `Transcript` struct to store student grades.

**Requirements**:
- Fields:
  - `id: UID` - Unique identifier for the object
  - `student_id: ID` - Link to the Student object from Unit One
  - `history: u8` - Grade for history (0-100)
  - `math: u8` - Grade for math (0-100)
  - `literature: u8` - Grade for literature (0-100)
- Abilities: `key` and `store`
  - `key`: Makes it a Sui object (can be stored globally)
  - `store`: Allows it to be stored inside other objects

**Example**:
```move
public struct Transcript has key, store {
    id: UID,
    student_id: ID,
    history: u8,
    math: u8,
    literature: u8,
}
```

**Key Concept**: The `store` ability is crucial because it allows the `Transcript` to be wrapped inside another object (like `WrappedTranscript`).

---

### TODO 4: Define the WrappedTranscript Struct

**Objective**: Create a wrapper struct for secure transcript transfer.

**Requirements**:
- Fields:
  - `id: UID` - Unique identifier
  - `transcript: Transcript` - The transcript being wrapped
  - `intended_address: address` - The address that should receive the transcript
- Abilities: `key` only (not `store`, as it won't be stored inside other objects)

**Example**:
```move
public struct WrappedTranscript has key {
    id: UID,
    transcript: Transcript,
    intended_address: address,
}
```

**Key Concept**: This pattern allows secure transfer - only the `intended_address` can unwrap and access the transcript.

---

### TODO 5: Define the TeacherCap Struct

**Objective**: Create a capability object that grants teacher privileges.

**Requirements**:
- Fields:
  - `id: UID` - Unique identifier
- Abilities: `key` only

**Example**:
```move
public struct TeacherCap has key {
    id: UID,
}
```

**Key Concept**: Capability objects are a common pattern in Move for access control. Only holders of `TeacherCap` can perform privileged operations.

---

### TODO 6: Module Initialization

**Objective**: Issue a `TeacherCap` to the module publisher when the module is first published.

**Requirements**:
- Function name: `init`
- Takes `ctx: &mut TxContext` as parameter
- Creates a new `TeacherCap` and transfers it to `ctx.sender()`

**Example**:
```move
/// Module initializer is called only once on module publish.
fun init(ctx: &mut TxContext) {
    transfer::transfer(
        TeacherCap {
            id: object::new(ctx),
        },
        ctx.sender(),
    );
}
```

**Key Concept**: The `init` function runs automatically once when the module is published, making it perfect for initial setup.

---

### TODO 7: TeacherCap Management

**Objective**: Allow existing teachers to grant teacher privileges to new addresses.

**Requirements**:
- Function name: `add_teacher` (or `add_additional_teacher`)
- Takes `_: &TeacherCap` (to prove the caller is a teacher)
- Takes `new_teacher_address: address`
- Takes `ctx: &mut TxContext`
- Creates and transfers a new `TeacherCap` to the new address

**Example**:
```move
public fun add_teacher(
    _: &TeacherCap,
    new_teacher_address: address,
    ctx: &mut TxContext,
) {
    transfer::transfer(
        TeacherCap {
            id: object::new(ctx),
        },
        new_teacher_address,
    );
}
```

**Key Concept**: Using `_: &TeacherCap` means the function requires a `TeacherCap` object but doesn't consume it (the `_` means it's unused).

---

### TODO 8: Transcript Creation

**Objective**: Allow teachers to create new transcripts.

**Requirements**:
- Function name: `create_transcript`
- Takes `_: &TeacherCap` (to prove the caller is a teacher)
- Takes `student_id: ID`
- Takes `history: u8`, `math: u8`, `literature: u8`
- Takes `ctx: &mut TxContext`
- Creates a new `Transcript` and transfers it to the teacher

**Example**:
```move
#[allow(lint(self_transfer))]
public fun create_transcript(
    _: &TeacherCap,
    student_id: ID,
    history: u8,
    math: u8,
    literature: u8,
    ctx: &mut TxContext,
) {
    let transcript = Transcript {
        id: object::new(ctx),
        student_id,
        history,
        math,
        literature,
    };
    transfer::public_transfer(transcript, ctx.sender());
}
```

**Note**: The `#[allow(lint(self_transfer))]` annotation suppresses a lint warning when transferring to the sender.

---

### TODO 9: Transcript Operations

**Objective**: Implement three functions with different access levels.

#### 9a. View Grade (Read-Only)

**Requirements**:
- Function name: `view_grade` (or `view_score`)
- Takes `transcript: &Transcript` (immutable reference)
- Returns the requested grade (e.g., `u8`)

**Example**:
```move
public fun view_grade(transcript: &Transcript): u8 {
    transcript.literature  // or any field you want to expose
}
```

#### 9b. Update Grade (Requires TeacherCap)

**Requirements**:
- Function name: `update_grade` (or `update_score`)
- Takes `_: &TeacherCap`
- Takes `transcript: &mut Transcript` (mutable reference)
- Takes `score: u8`
- Updates the specified grade field

**Example**:
```move
public fun update_grade(
    _: &TeacherCap,
    transcript: &mut Transcript,
    score: u8,
) {
    transcript.literature = score;
}
```

#### 9c. Delete Transcript (Requires TeacherCap)

**Requirements**:
- Function name: `delete_transcript`
- Takes `_: &TeacherCap`
- Takes `transcript: Transcript` (by value, not reference)
- Destroys the transcript object

**Example**:
```move
public fun delete_transcript(
    _: &TeacherCap,
    transcript: Transcript,
) {
    let Transcript { id, .. } = transcript;
    id.delete();
}
```

**Key Concept**: Notice the different parameter types:
- `&Transcript` - Read-only access
- `&mut Transcript` - Mutable access
- `Transcript` - Ownership transfer (required for deletion)

---

### TODO 10: Secure Transcript Transfer

**Objective**: Implement wrapping and unwrapping for secure transfer.

#### 10a. Wrap Transcript

**Requirements**:
- Function name: `wrap_transcript` (or `request_transcript`)
- Takes `transcript: Transcript` (by value)
- Takes `intended_address: address`
- Takes `ctx: &mut TxContext`
- Creates a `WrappedTranscript`
- Emits a `TranscriptRequestEvent` (see TODO 11)
- Transfers the wrapped transcript to the intended address

**Example**:
```move
public fun wrap_transcript(
    transcript: Transcript,
    intended_address: address,
    ctx: &mut TxContext,
) {
    let wrapped = WrappedTranscript {
        id: object::new(ctx),
        transcript,
        intended_address,
    };
    
    event::emit(TranscriptRequestEvent {
        transcript_id: object::id(&wrapped),
        requester: ctx.sender(),
        intended_address,
    });
    
    transfer::transfer(wrapped, intended_address);
}
```

#### 10b. Unwrap Transcript

**Requirements**:
- Function name: `unpack_transcript` (or `unpack_wrapped_transcript`)
- Takes `wrapped: WrappedTranscript` (by value)
- Takes `ctx: &mut TxContext`
- Verifies that `ctx.sender()` matches `intended_address`
- Unwraps the transcript and transfers it to the sender
- Deletes the wrapper object

**Example**:
```move
const E_NOT_INTENDED_ADDRESS: u64 = 1;

public fun unpack_transcript(
    wrapped: WrappedTranscript,
    ctx: &mut TxContext,
) {
    assert!(wrapped.intended_address == ctx.sender(), E_NOT_INTENDED_ADDRESS);
    
    let WrappedTranscript { id, transcript, .. } = wrapped;
    transfer::transfer(transcript, ctx.sender());
    id.delete();
}
```

**Key Concept**: The `assert!` ensures only the intended recipient can unwrap the transcript, providing security.

---

### TODO 11: Events

**Objective**: Define and emit events for transcript requests.

**Requirements**:
- Struct name: `TranscriptRequestEvent`
- Abilities: `copy`, `drop` (required for events)
- Fields:
  - `transcript_id: ID` - The ID of the wrapped transcript
  - `requester: address` - Who requested the transcript
  - `intended_address: address` - Who should receive it
- Emit this event in `wrap_transcript`

**Example**:
```move
public struct TranscriptRequestEvent has copy, drop {
    transcript_id: ID,
    requester: address,
    intended_address: address,
}
```

**Key Concept**: Events are logged on-chain and can be queried later, providing an audit trail.

---

## Reference Implementation

Here's a complete reference implementation based on the Sui Move intro course:

```move
module sui_intro_unit_two::transcript;

use sui::event;
use sui::transfer;
use sui::object::{Self, UID, ID};
use sui::tx_context::{Self, TxContext};

public struct Transcript has key, store {
    id: UID,
    student_id: ID,
    history: u8,
    math: u8,
    literature: u8,
}

public struct WrappedTranscript has key {
    id: UID,
    transcript: Transcript,
    intended_address: address,
}

public struct TeacherCap has key {
    id: UID,
}

public struct TranscriptRequestEvent has copy, drop {
    transcript_id: ID,
    requester: address,
    intended_address: address,
}

const E_NOT_INTENDED_ADDRESS: u64 = 1;

fun init(ctx: &mut TxContext) {
    transfer::transfer(
        TeacherCap {
            id: object::new(ctx),
        },
        ctx.sender(),
    );
}

public fun add_teacher(
    _: &TeacherCap,
    new_teacher_address: address,
    ctx: &mut TxContext,
) {
    transfer::transfer(
        TeacherCap {
            id: object::new(ctx),
        },
        new_teacher_address,
    );
}

#[allow(lint(self_transfer))]
public fun create_transcript(
    _: &TeacherCap,
    student_id: ID,
    history: u8,
    math: u8,
    literature: u8,
    ctx: &mut TxContext,
) {
    let transcript = Transcript {
        id: object::new(ctx),
        student_id,
        history,
        math,
        literature,
    };
    transfer::public_transfer(transcript, ctx.sender());
}

public fun view_grade(transcript: &Transcript): u8 {
    transcript.literature
}

public fun update_grade(
    _: &TeacherCap,
    transcript: &mut Transcript,
    score: u8,
) {
    transcript.literature = score;
}

public fun delete_transcript(
    _: &TeacherCap,
    transcript: Transcript,
) {
    let Transcript { id, .. } = transcript;
    id.delete();
}

public fun wrap_transcript(
    transcript: Transcript,
    intended_address: address,
    ctx: &mut TxContext,
) {
    let wrapped = WrappedTranscript {
        id: object::new(ctx),
        transcript,
        intended_address,
    };
    
    event::emit(TranscriptRequestEvent {
        transcript_id: object::id(&wrapped),
        requester: ctx.sender(),
        intended_address,
    });
    
    transfer::transfer(wrapped, intended_address);
}

#[allow(lint(self_transfer))]
public fun unpack_transcript(
    wrapped: WrappedTranscript,
    ctx: &mut TxContext,
) {
    assert!(wrapped.intended_address == ctx.sender(), E_NOT_INTENDED_ADDRESS);
    
    let WrappedTranscript { id, transcript, .. } = wrapped;
    transfer::transfer(transcript, ctx.sender());
    id.delete();
}
```

---

## Testing Your Implementation

### 1. Build the Package

```bash
cd task_two
sui move build
```

Fix any compilation errors before proceeding.

### 2. Run Tests

```bash
sui move test
```

### 3. Publish to Local Network

```bash
sui client publish --gas-budget 10000000
```

Save the package ID from the output.

### 4. Test Functions

#### Create a Transcript

```bash
sui client call \
  --function create_transcript \
  --module task_two \
  --package <PACKAGE_ID> \
  --args <TEACHER_CAP_ID> <STUDENT_ID> 85 90 88 \
  --gas-budget 10000000
```

#### View a Grade

```bash
sui client call \
  --function view_grade \
  --module task_two \
  --package <PACKAGE_ID> \
  --args <TRANSCRIPT_ID> \
  --gas-budget 10000000
```

#### Update a Grade

```bash
sui client call \
  --function update_grade \
  --module task_two \
  --package <PACKAGE_ID> \
  --args <TEACHER_CAP_ID> <TRANSCRIPT_ID> 92 \
  --gas-budget 10000000
```

#### Wrap a Transcript

```bash
sui client call \
  --function wrap_transcript \
  --module task_two \
  --package <PACKAGE_ID> \
  --args <TRANSCRIPT_ID> <INTENDED_ADDRESS> \
  --gas-budget 10000000
```

#### Unpack a Transcript

```bash
sui client call \
  --function unpack_transcript \
  --module task_two \
  --package <PACKAGE_ID> \
  --args <WRAPPED_TRANSCRIPT_ID> \
  --gas-budget 10000000
```

---

## Key Concepts Explained

### Abilities

Move uses four abilities that control what you can do with a type:

- **`key`**: The type can be used as a Sui object (has global identity)
- **`store`**: The type can be stored inside other objects
- **`drop`**: The type can be discarded (not required for deletion)
- **`copy`**: The type can be copied (duplicated)

For `Transcript`:
- `key`: Makes it a Sui object with a unique ID
- `store`: Allows it to be stored inside `WrappedTranscript`

For `WrappedTranscript`:
- `key`: Makes it a Sui object
- No `store`: It's not meant to be stored inside other objects

### Access Control Patterns

1. **Public Functions**: Anyone can call (e.g., `view_grade`)
2. **Capability-Based**: Requires a capability object (e.g., `TeacherCap`)
3. **Ownership-Based**: Requires owning the object (e.g., `unpack_transcript`)

### Wrapping Pattern

Wrapping is a security pattern that:
1. Encapsulates an object inside a wrapper
2. Stores access control information (e.g., `intended_address`)
3. Only allows unwrapping by authorized parties
4. Provides auditability through events

---

## Troubleshooting

### Common Errors

#### "Unused variable"
- Use `_` prefix for intentionally unused parameters (e.g., `_: &TeacherCap`)

#### "Missing ability"
- Ensure structs have correct abilities for their use case
- `Transcript` needs `store` to be wrapped
- `WrappedTranscript` needs `key` to be a Sui object

#### "Cannot transfer object"
- Check that you're using the correct transfer function
- `transfer::transfer()` for owned objects
- `transfer::public_transfer()` for objects with `store` ability

#### "Assertion failed"
- Verify the `intended_address` matches `ctx.sender()` in `unpack_transcript`
- Check error constants are defined correctly

#### "Module not found"
- Ensure module name matches package name in `Move.toml`
- Check import statements are correct

### Build Issues

1. **Syntax errors**: Check for missing semicolons, commas, braces
2. **Type mismatches**: Verify parameter types match function signatures
3. **Missing imports**: Ensure all required Sui modules are imported

---

## Stretch Goals (Optional)

Once you've completed the basic requirements, try these enhancements:

1. **View All Grades**: Create a function that returns all three grades at once
2. **Batch Updates**: Allow updating multiple grades in one transaction
3. **Transcript Metadata**: Add fields like `student_name`, `date_created`, `semester`
4. **Multiple Subjects**: Extend to support variable number of subjects
5. **Grade History**: Track grade changes over time
6. **Access Logging**: Log all transcript access attempts
7. **Bulk Operations**: Functions to manage multiple transcripts at once

---

## Resources

- [Sui Move Documentation](https://docs.sui.io/build/move)
- [Sui Move Intro Course](https://github.com/sui-foundation/sui-move-intro-course)
- [Move Language Book](https://move-language.github.io/move/)
- [Sui CLI Reference](https://docs.sui.io/build/cli)

---

## Submission Checklist

Before submitting your work, ensure:

- [ ] All TODOs are implemented
- [ ] Code compiles without errors (`sui move build`)
- [ ] All functions are properly tested
- [ ] Code follows Move conventions
- [ ] Comments explain complex logic
- [ ] Error codes are defined for assertions
- [ ] Events are properly emitted
- [ ] Access control is correctly implemented

---

## Next Steps

After completing this task, you should:

1. Review your code and compare with the reference implementation
2. Test all functions thoroughly
3. Understand why each design decision was made
4. Consider how you might extend the system
5. Move on to the next unit in the course

Good luck with your implementation! 🚀

