# frozen_string_literal: true

require_relative 'test_helper'

class TestPushLine < Test::Unit::TestCase
  def setup
    @repl = Rubish::REPL.new
    # setup_reline only fires in repl.run; the install is what wires
    # push-line into Reline, so trigger it explicitly for tests.
    Rubish::Builtins.install_push_line
    state = Rubish::Builtins.current_state
    state.push_line_stack.clear
    state.push_line_pending = false
    Reline.pre_input_hook = nil
  end

  def teardown
    state = Rubish::Builtins.current_state
    state.push_line_stack.clear
    state.push_line_pending = false
    Reline.pre_input_hook = nil
  end

  def test_method_installed_on_line_editor
    assert Reline::LineEditor.method_defined?(:rubish_push_line)
  end

  def test_install_is_idempotent
    Rubish::Builtins.install_push_line
    Rubish::Builtins.install_push_line
    assert Reline::LineEditor.method_defined?(:rubish_push_line)
  end

  def test_bound_to_esc_q_in_emacs_keymap
    defaults = Reline.core.config.instance_variable_get(:@default_key_bindings)
    bindings = defaults[:emacs].instance_variable_get(:@key_bindings)
    assert_equal :rubish_push_line, bindings[[0x1B, 0x51]], 'ESC-Q bound'
    assert_equal :rubish_push_line, bindings[[0x1B, 0x71]], 'ESC-q bound'
  end

  # push-line stashes the buffer onto the stack and sets the pending
  # flag. Crucially it does NOT clear @buffer_of_lines — leaving the
  # buffer intact lets Reline's render_finished print the line into
  # scrollback, which is the zsh-style visual.
  def test_handler_stashes_without_clearing_buffer
    state = Rubish::Builtins.current_state
    le = build_line_editor(['cat very-long-pipeline | grep foo'])
    le.byte_pointer = le.current_line.bytesize

    le.rubish_push_line

    assert_equal ['cat very-long-pipeline | grep foo'], state.push_line_stack
    assert state.push_line_pending, 'pending flag set so REPL skips exec'
    assert_equal ['cat very-long-pipeline | grep foo'],
                 le.instance_variable_get(:@buffer_of_lines),
                 'buffer kept intact so render_finished preserves the line on screen'
    assert le.finished?
    assert_nil Reline.pre_input_hook,
               'handler does NOT arm the restore hook — that happens at pre-readline of the prompt *after* the interjection'
  end

  def test_handler_on_empty_buffer_still_sets_pending_but_does_not_stash
    state = Rubish::Builtins.current_state
    le = build_line_editor([''])

    le.rubish_push_line

    assert_empty state.push_line_stack
    assert state.push_line_pending,
           'even an empty push sets pending so REPL skips the empty-string branch path consistently'
    assert le.finished?
  end

  # The pre-readline coordinator's first job: when push_line_pending is
  # set (we just returned from a push), the upcoming prompt is the
  # interjection prompt — clear the flag and do not arm a restore.
  def test_configure_clears_pending_and_does_not_arm_on_interjection_prompt
    state = Rubish::Builtins.current_state
    state.push_line_stack << 'stashed-thing'
    state.push_line_pending = true

    Rubish::Builtins.configure_push_line_restore

    assert_equal false, state.push_line_pending
    assert_nil Reline.pre_input_hook
    assert_equal ['stashed-thing'], state.push_line_stack,
                 'stack untouched — restore happens on the prompt AFTER the interjection'
  end

  # Second job: when not in the pending state but the stack has
  # entries, install a hook that pops the top entry and clears itself
  # once the stack drains.
  def test_configure_arms_pop_hook_when_not_pending_and_stack_nonempty
    state = Rubish::Builtins.current_state
    state.push_line_stack.concat(['first', 'second'])
    state.push_line_pending = false

    Rubish::Builtins.configure_push_line_restore
    assert_not_nil Reline.pre_input_hook, 'hook armed'

    # Simulate the hook firing on the next prompt's readline init: pop
    # the top (LIFO → "second") into a target line editor.
    target = build_line_editor([''])
    Reline.core.instance_variable_set(:@line_editor, target)
    Reline.pre_input_hook.call
    assert_equal 'second', target.whole_buffer
    assert_equal ['first'], state.push_line_stack
    assert_not_nil Reline.pre_input_hook, 'hook stays while stack non-empty'

    # Next prompt: pops "first", then clears the hook.
    target2 = build_line_editor([''])
    Reline.core.instance_variable_set(:@line_editor, target2)
    Reline.pre_input_hook.call
    assert_equal 'first', target2.whole_buffer
    assert_empty state.push_line_stack
    assert_nil Reline.pre_input_hook, 'hook clears once stack drains'
  end

  def test_configure_is_noop_when_clean
    state = Rubish::Builtins.current_state
    assert_empty state.push_line_stack
    assert_equal false, state.push_line_pending

    Rubish::Builtins.configure_push_line_restore

    assert_nil Reline.pre_input_hook
  end

  # End-to-end state-machine walkthrough of the canonical zsh flow:
  # user types A, pushes; interjection prompt is blank; types and runs
  # B; next prompt restores A.
  def test_full_push_interject_restore_flow
    state = Rubish::Builtins.current_state

    # === Prompt 1: user types A and pushes ===
    le1 = build_line_editor(['typed-A'])
    le1.byte_pointer = le1.current_line.bytesize
    le1.rubish_push_line
    assert state.push_line_pending
    assert_equal ['typed-A'], state.push_line_stack
    # REPL sees push_line_pending → skips exec/history. Loop continues.

    # === Prompt 2: the interjection prompt ===
    Rubish::Builtins.configure_push_line_restore
    assert_equal false, state.push_line_pending, 'pending cleared at interjection prompt setup'
    assert_nil Reline.pre_input_hook, 'no restore on interjection prompt'
    # User types B and submits normally — no push_line state change.
    # REPL executes B.

    # === Prompt 3: the prompt after the interjection ===
    Rubish::Builtins.configure_push_line_restore
    assert_not_nil Reline.pre_input_hook, 'restore armed now'

    target = build_line_editor([''])
    Reline.core.instance_variable_set(:@line_editor, target)
    Reline.pre_input_hook.call
    assert_equal 'typed-A', target.whole_buffer, 'A restored'
    assert_empty state.push_line_stack
    assert_nil Reline.pre_input_hook
  end

  # Two pushes in a row (without an interjection in between) stack
  # LIFO; both come back over the two prompts after the eventual
  # interjection.
  def test_double_push_then_interject_then_two_restore_prompts
    state = Rubish::Builtins.current_state

    # Prompt 1: type cmd1, push.
    le1 = build_line_editor(['cmd1'])
    le1.byte_pointer = le1.current_line.bytesize
    le1.rubish_push_line
    assert state.push_line_pending

    # Prompt 2: pre-readline setup (interjection prompt, no restore).
    Rubish::Builtins.configure_push_line_restore
    assert_nil Reline.pre_input_hook
    # User pushes again instead of interjecting.
    le2 = build_line_editor(['cmd2'])
    le2.byte_pointer = le2.current_line.bytesize
    le2.rubish_push_line
    assert state.push_line_pending
    assert_equal ['cmd1', 'cmd2'], state.push_line_stack

    # Prompt 3: still interjection prompt (no restore yet).
    Rubish::Builtins.configure_push_line_restore
    assert_nil Reline.pre_input_hook
    # User types real interjection and submits. Exec runs.

    # Prompt 4: now arm the restore.
    Rubish::Builtins.configure_push_line_restore
    target_a = build_line_editor([''])
    Reline.core.instance_variable_set(:@line_editor, target_a)
    Reline.pre_input_hook.call
    assert_equal 'cmd2', target_a.whole_buffer, 'LIFO: cmd2 pops first'
    assert_equal ['cmd1'], state.push_line_stack
    assert_not_nil Reline.pre_input_hook

    # Prompt 5: user accepts/edits cmd2, exec. Then next prompt pops cmd1.
    Rubish::Builtins.configure_push_line_restore
    target_b = build_line_editor([''])
    Reline.core.instance_variable_set(:@line_editor, target_b)
    Reline.pre_input_hook.call
    assert_equal 'cmd1', target_b.whole_buffer
    assert_empty state.push_line_stack
    assert_nil Reline.pre_input_hook
  end

  def test_multiline_buffer_round_trips
    state = Rubish::Builtins.current_state
    le = build_line_editor(['for f in *.rb', 'do', '  echo $f', 'done'])
    le.instance_variable_set(:@line_index, 3)
    le.byte_pointer = le.current_line.bytesize
    le.rubish_push_line

    assert_equal ["for f in *.rb\ndo\n  echo $f\ndone"], state.push_line_stack

    # Skip the interjection prompt.
    Rubish::Builtins.configure_push_line_restore  # pending → cleared, no hook
    # Now arm restore.
    Rubish::Builtins.configure_push_line_restore

    target = build_line_editor([''])
    Reline.core.instance_variable_set(:@line_editor, target)
    Reline.pre_input_hook.call

    assert_equal ['for f in *.rb', 'do', '  echo $f', 'done'],
                 target.instance_variable_get(:@buffer_of_lines)
  end

  private

  # Build a real Reline::LineEditor with the given buffer contents, set
  # as Reline.core's active editor so `Reline.insert_text` writes into it.
  def build_line_editor(lines)
    editor = Reline::LineEditor.new(Reline::Config.new)
    editor.reset('')
    editor.instance_variable_set(:@buffer_of_lines, lines.dup)
    editor.instance_variable_set(:@line_index, lines.length - 1)
    editor.byte_pointer = 0
    Reline.core.instance_variable_set(:@line_editor, editor)
    editor
  end
end
