//===- TestInterfaces.cpp - Test interface generation and application -----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "TestTypes.h"
#include "mlir/Pass/Pass.h"

using namespace mlir;

namespace {
/// This test checks various aspects of Type interface generation and
/// application.
struct TestTypeInterfaces
    : public PassWrapper<TestTypeInterfaces, OperationPass<ModuleOp>> {
  void runOnOperation() override {
    getOperation().walk([](Operation *op) {
      for (Type type : op->getResultTypes()) {
        if (auto testInterface = type.dyn_cast<TestTypeInterface>()) {
          testInterface.printTypeA(op->getLoc());
          testInterface.printTypeB(op->getLoc());
          testInterface.printTypeC(op->getLoc());
          testInterface.printTypeD(op->getLoc());
        }
        if (auto testType = type.dyn_cast<TestType>())
          testType.printTypeE(op->getLoc());
      }
    });
  }
};
} // end anonymous namespace

namespace mlir {
void registerTestInterfaces() {
  PassRegistration<TestTypeInterfaces> pass("test-type-interfaces",
                                            "Test type interface support.");
}
} // namespace mlir
