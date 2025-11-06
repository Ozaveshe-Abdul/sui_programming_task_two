// #[allow(duplicate_alias)]
#[allow(lint(self_transfer))]

module task_two::transcript;

use sui::event::emit;
// use std::string::String;

#[error]
const ENotOwner: vector<u8> = b"not object owner";

public struct Transcript has key, store {
    id: UID,
    student_id: ID,
    student_name: vector<u8>,
    date: u8,
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
    intended_address: address
}

fun init(ctx: &mut TxContext) {
    // Ensure this function is only called once during module publication
    let cap = TeacherCap { id: object::new(ctx) };

    transfer::transfer(cap, ctx.sender());
}

public fun add_teacher(_: &TeacherCap, new_teacher: address, ctx: &mut TxContext) {
    let new_cap = TeacherCap { id: object::new(ctx) };

    transfer::transfer(new_cap, new_teacher);
}

public fun view_grade(transcript: &Transcript, subject: vector<u8>): u8 {
    if (subject == b"history") {
        transcript.history
    } else if (subject == b"math") {
        transcript.math
    } else {
        transcript.literature
    }
}

public fun update_grade(_: &TeacherCap, transcript: &mut Transcript, subject: vector<u8>, new_grade: u8) {
    if (subject == b"history") {
        transcript.history = new_grade;     
    } else if (subject == b"math") {
        transcript.math = new_grade;
    } else {
        transcript.literature = new_grade;
    }
}

public fun delete_transcript(_: &TeacherCap, transcript: Transcript) {
    // Transcript object will be deleted when it goes out of scope
    let Transcript {id, ..} = transcript;
    id.delete();
}

public fun create_default_transcript(
       ctx: &mut TxContext, student_id: ID
) {
    let transcript = Transcript {
        id: object::new(ctx),
        student_id,
        student_name: b"Abdul",
        date: 0,
        history: 0,
        math: 0,
        literature: 0,
    };

    transfer::transfer(transcript, ctx.sender());
}

public fun create_transcript(
    _: &TeacherCap,
    student_id: ID,
    student_name: vector<u8>,
    date: u8,
    history: u8,
    math: u8,
    literature: u8,
    ctx: &mut TxContext
) {
    let transcript = Transcript {
        id: object::new(ctx),
        student_id,
        student_name,
        date,
        history,
        math,
        literature,
    };

    transfer::transfer(transcript, ctx.sender());
}

public fun wrap_transcript(
    transcript: Transcript,
    intended_address: address,
    ctx: &mut TxContext
) {
    let wrapped_transcript = WrappedTranscript {
        id: object::new(ctx),
        transcript,
        intended_address,
    };


    emit(
        TranscriptRequestEvent{
            transcript_id: object::id(&wrapped_transcript),
            requester: ctx.sender(),
            intended_address
        }
    );

    transfer::transfer(wrapped_transcript, intended_address);

}

public fun unwrap_transcript(
    wrapped: WrappedTranscript,
    ctx: &mut TxContext
) {
    assert!(ctx.sender() == wrapped.intended_address, ENotOwner);
    
    let WrappedTranscript {id, transcript, ..} = wrapped;

    transfer::transfer(transcript, ctx.sender());

    id.delete();
}

public fun view_all_grades(transcript: &Transcript): (u8, u8, u8) {
    (transcript.history, transcript.math, transcript.literature)
}

public fun batch_updates(
        _: &TeacherCap, 
        transcript: &mut Transcript, 
        new_history_grade: u8,
        new_math_grade: u8,
        new_literature_grade: u8
    ) {
    transcript.history = new_history_grade;
    transcript.math = new_math_grade;
    transcript.literature = new_literature_grade;
}