// RUN: mlir-opt %s -split-input-file -verify-diagnostics

// expected-error @below {{expects the entry block to have one argument of type implementing TransformHandleTypeInterface}}
transform.sequence failures(propagate) {
}

// -----

// expected-note @below {{nested in another possible top-level op}}
transform.sequence failures(propagate) {
^bb0(%arg0: !pdl.operation):
  // expected-error @below {{expects the root operation to be provided for a nested op}}
  transform.sequence failures(propagate) {
  ^bb1(%arg1: !pdl.operation):
  }
}

// -----

// expected-error @below {{expected children ops to implement TransformOpInterface}}
transform.sequence failures(propagate) {
^bb0(%arg0: !pdl.operation):
  // expected-note @below {{op without interface}}
  arith.constant 42.0 : f32
}

// -----

// expected-error @below {{expects the types of the terminator operands to match the types of the result}}
%0 = transform.sequence -> !pdl.operation failures(propagate) {
^bb0(%arg0: !pdl.operation):
  // expected-note @below {{terminator}}
  transform.yield
}

// -----

transform.sequence failures(propagate) {
^bb0(%arg0: !transform.any_op):
  // expected-error @below {{expects the type of the block argument to match the type of the operand}}
  transform.sequence %arg0: !transform.any_op failures(propagate) {
  ^bb1(%arg1: !pdl.operation):
    transform.yield
  }
}

// -----

// expected-note @below {{nested in another possible top-level op}}
transform.with_pdl_patterns {
^bb0(%arg0: !pdl.operation):
  // expected-error @below {{expects the root operation to be provided for a nested op}}
  transform.sequence failures(propagate) {
  ^bb1(%arg1: !pdl.operation):
  }
}

// -----

// expected-error @below {{expects only one non-pattern op in its body}}
transform.with_pdl_patterns {
^bb0(%arg0: !pdl.operation):
  // expected-note @below {{first non-pattern op}}
  transform.sequence failures(propagate) {
  ^bb1(%arg1: !pdl.operation):
  }
  // expected-note @below {{second non-pattern op}}
  transform.sequence failures(propagate) {
  ^bb1(%arg1: !pdl.operation):
  }
}

// -----

// expected-error @below {{expects only pattern and top-level transform ops in its body}}
transform.with_pdl_patterns {
^bb0(%arg0: !pdl.operation):
  // expected-note @below {{offending op}}
  "test.something"() : () -> ()
}

// -----

// expected-note @below {{parent operation}}
transform.with_pdl_patterns {
^bb0(%arg0: !pdl.operation):
   // expected-error @below {{op cannot be nested}}
  transform.with_pdl_patterns %arg0 : !pdl.operation {
  ^bb1(%arg1: !pdl.operation):
  }
}

// -----

// expected-error @below {{expects at least one region}}
"transform.test_transform_unrestricted_op_no_interface"() : () -> ()

// -----

// expected-error @below {{expects a single-block region}}
"transform.test_transform_unrestricted_op_no_interface"() ({
^bb0(%arg0: !pdl.operation):
  "test.potential_terminator"() : () -> ()
^bb1:
  "test.potential_terminator"() : () -> ()
}) : () -> ()

// -----

transform.sequence failures(propagate) {
^bb0(%arg0: !pdl.operation):
  // expected-error @below {{result #0 has more than one potential consumer}}
  %0 = test_produce_param_or_forward_operand 42
  // expected-note @below {{used here as operand #0}}
  test_consume_operand_if_matches_param_or_fail %0[42]
  // expected-note @below {{used here as operand #0}}
  test_consume_operand_if_matches_param_or_fail %0[42]
}

// -----

transform.sequence failures(propagate) {
^bb0(%arg0: !pdl.operation):
  // expected-error @below {{result #0 has more than one potential consumer}}
  %0 = test_produce_param_or_forward_operand 42
  // expected-note @below {{used here as operand #0}}
  test_consume_operand_if_matches_param_or_fail %0[42]
  // expected-note @below {{used here as operand #0}}
  transform.sequence %0 : !pdl.operation failures(propagate) {
  ^bb1(%arg1: !pdl.operation):
    test_consume_operand_if_matches_param_or_fail %arg1[42]
  }
}

// -----

transform.sequence failures(propagate) {
^bb0(%arg0: !pdl.operation):
  // expected-error @below {{result #0 has more than one potential consumer}}
  %0 = test_produce_param_or_forward_operand 42
  // expected-note @below {{used here as operand #0}}
  test_consume_operand_if_matches_param_or_fail %0[42]
  transform.sequence %0 : !pdl.operation failures(propagate) {
  ^bb1(%arg1: !pdl.operation):
    // expected-note @below {{used here as operand #0}}
    test_consume_operand_if_matches_param_or_fail %0[42]
  }
}

// -----

transform.sequence failures(propagate) {
^bb0(%arg0: !pdl.operation):
  // expected-error @below {{result #0 has more than one potential consumer}}
  %0 = test_produce_param_or_forward_operand 42
  // expected-note @below {{used here as operand #0}}
  test_consume_operand_if_matches_param_or_fail %0[42]
  // expected-note @below {{used here as operand #0}}
  transform.sequence %0 : !pdl.operation failures(propagate) {
  ^bb1(%arg1: !pdl.operation):
    transform.sequence %arg1 : !pdl.operation failures(propagate) {
    ^bb2(%arg2: !pdl.operation):
      test_consume_operand_if_matches_param_or_fail %arg2[42]
    }
  }
}

// -----

transform.sequence failures(propagate) {
^bb1(%arg1: !pdl.operation):
  // expected-error @below {{expects at least one region}}
  transform.alternatives
}

// -----

transform.sequence failures(propagate) {
^bb1(%arg1: !pdl.operation):
  // expected-error @below {{expects terminator operands to have the same type as results of the operation}}
  %2 = transform.alternatives %arg1 : !pdl.operation -> !pdl.operation {
  ^bb2(%arg2: !pdl.operation):
    transform.yield %arg2 : !pdl.operation
  }, {
  ^bb2(%arg2: !pdl.operation):
    // expected-note @below {{terminator}}
    transform.yield
  }
}

// -----

// expected-error @below {{expects the entry block to have one argument of type implementing TransformHandleTypeInterface}}
transform.alternatives {
^bb0:
  transform.yield
}

// -----

transform.sequence failures(propagate) {
^bb0(%arg0: !pdl.operation):
  // expected-error @below {{result #0 has more than one potential consumer}}
  %0 = test_produce_param_or_forward_operand 42
  // expected-note @below {{used here as operand #0}}
  transform.foreach %0 : !pdl.operation {
  ^bb1(%arg1: !pdl.operation):
    transform.test_consume_operand %arg1
  }
  // expected-note @below {{used here as operand #0}}
  transform.test_consume_operand %0
}
