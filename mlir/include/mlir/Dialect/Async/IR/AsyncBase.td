//===- AsyncBase.td ----------------------------------------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Base definitions for the `async` dialect.
//
//===----------------------------------------------------------------------===//

#ifndef ASYNC_BASE_TD
#define ASYNC_BASE_TD

include "mlir/IR/OpBase.td"

//===----------------------------------------------------------------------===//
// Async dialect definitions
//===----------------------------------------------------------------------===//

def AsyncDialect : Dialect {
  let name = "async";

  let summary = "Types and operations for async dialect";
  let description = [{
    This dialect contains operations for modeling asynchronous execution.
  }];

  let cppNamespace = "::mlir::async";
}

def Async_TokenType : DialectType<AsyncDialect,
    CPred<"$_self.isa<::mlir::async::TokenType>()">, "token type">,
    BuildableType<"$_builder.getType<::mlir::async::TokenType>()"> {
  let typeDescription = [{
    `async.token` is a type returned by asynchronous operations, and it becomes
    `ready` when the asynchronous operations that created it is completed.
  }];
}

class Async_ValueType<Type type>
    : DialectType<AsyncDialect,
        And<[
          CPred<"$_self.isa<::mlir::async::ValueType>()">,
          SubstLeaves<"$_self",
                      "$_self.cast<::mlir::async::ValueType>().getValueType()",
                      type.predicate>
       ]>, "async value type with " # type.description # " underlying type"> {
  let typeDescription = [{
    `async.value` represents a value returned by asynchronous operations,
    which may or may not be available currently, but will be available at some
    point in the future.
  }];

  Type valueType = type;
}

def Async_AnyValueType : DialectType<AsyncDialect,
                           CPred<"$_self.isa<::mlir::async::ValueType>()">,
                                 "async value type">;

def Async_AnyValueOrTokenType : AnyTypeOf<[Async_AnyValueType,
                                           Async_TokenType]>;

#endif // ASYNC_BASE_TD
