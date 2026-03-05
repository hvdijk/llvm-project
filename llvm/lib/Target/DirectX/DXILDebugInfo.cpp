//===- DXILDebugInfo.cpp - analysis and lowering for Debug info -*- C++ -*- -=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "DXILDebugInfo.h"
#include "DirectX.h"
#include "llvm/IR/Module.h"
#include "llvm/InitializePasses.h"
#include "llvm/Pass.h"

#define DEBUG_TYPE "dxil-debug-info"

using namespace llvm;

PreservedAnalyses DXILDebugInfo::run(Module &M, ModuleAnalysisManager &MAM) {
  return PreservedAnalyses::all();
}

namespace {
class DXILDebugInfoLegacy : public ModulePass {
public:
  bool runOnModule(Module &M) override { return false; }

  StringRef getPassName() const override { return "DXIL Debug Info"; }
  DXILDebugInfoLegacy() : ModulePass(ID) {}

  static char ID; // Pass identification.
  void getAnalysisUsage(llvm::AnalysisUsage &AU) const override {}
};
char DXILDebugInfoLegacy::ID = 0;
} // end anonymous namespace

INITIALIZE_PASS_BEGIN(DXILDebugInfoLegacy, DEBUG_TYPE, "DXIL Debug Info", false,
                      false)
INITIALIZE_PASS_END(DXILDebugInfoLegacy, DEBUG_TYPE, "DXIL Debug Info", false,
                    false)

ModulePass *llvm::createDXILDebugInfoLegacyPass() {
  return new DXILDebugInfoLegacy();
}
