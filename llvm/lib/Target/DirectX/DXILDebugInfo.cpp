//===- DXILDebugInfo.cpp - analysis and lowering for Debug info -*- C++ -*- -=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "DXILDebugInfo.h"
#include "DirectX.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/DenseSet.h"
#include "llvm/IR/DebugInfo.h"
#include "llvm/IR/DebugInfoMetadata.h"
#include "llvm/IR/Module.h"
#include "llvm/InitializePasses.h"
#include "llvm/Pass.h"

#define DEBUG_TYPE "dxil-debug-info"

using namespace llvm;

enum DXDINodeKind {
  DXDIGlobalVariable,
};

static StringRef getDXDINodeName(DXDINodeKind Kind) {
  switch (Kind) {
  case DXDIGlobalVariable:
    return "DXDIGlobalVariable";
  }
  return "invalid";
}

class DIRewriter {
public:
  DIRewriter(Module &M, DebugInfoFinder &DIF) : M(M), DIF(DIF) {}
  bool run();

  bool rewriteDIGlobalVariableExpression();

private:
  MDTuple *create(DXDINodeKind Kind, ArrayRef<Metadata *> MDs,
                  ArrayRef<MDOperand> OrigOps = ArrayRef<MDOperand>());
  ConstantAsMetadata *createConstant(uint64_t Val);

  Module &M;
  DebugInfoFinder &DIF;
};

MDTuple *DIRewriter::create(DXDINodeKind Kind, ArrayRef<Metadata *> MDs,
                            ArrayRef<MDOperand> OrigOps) {
  SmallVector<Metadata *, 32> Operands;
  Operands.push_back(MDString::get(M.getContext(), getDXDINodeName(Kind)));
  Operands.append(MDs.begin(), MDs.end());

  for (const MDOperand &Op : OrigOps) {
    Operands.push_back(Op.get());
  }

  return MDTuple::get(M.getContext(), Operands);
}

ConstantAsMetadata *DIRewriter::createConstant(uint64_t V) {
  ConstantInt *IntV = ConstantInt::get(Type::getInt64Ty(M.getContext()), V);
  return ConstantAsMetadata::get(IntV);
}

bool DIRewriter::run() {
  bool Changed = false;
  Changed |= rewriteDIGlobalVariableExpression();
  return Changed;
}

bool DIRewriter::rewriteDIGlobalVariableExpression() {
  DenseMap<MDNode *, MDTuple *> NodesToReplace;

  for (DIGlobalVariableExpression *DGVE : DIF.global_variables()) {
    DIGlobalVariable *DGV = DGVE->getVariable();
    DIExpression *DExpr = DGVE->getExpression();

    Metadata *NewOps[] = {DExpr, createConstant(DGV->getLine()),
                          createConstant(DGV->isLocalToUnit()),
                          createConstant(DGV->isDefinition())};

    MDTuple *NewDGV = create(DXDIGlobalVariable, NewOps, DGV->operands());
    NodesToReplace[DGVE] = NewDGV;
  }

  // Replace references from compile units.
  for (DICompileUnit *CU : DIF.compile_units()) {
    DIGlobalVariableExpressionArray Vars = CU->getGlobalVariables();
    for (unsigned I = 0; I < Vars.size(); ++I) {
      DIGlobalVariableExpression *DGVE = Vars[I];
      auto NewDGVIt = NodesToReplace.find(DGVE);
      if (NewDGVIt != NodesToReplace.end()) {
        Vars->replaceOperandWith(I, NewDGVIt->second);
      }
    }
  }

  // Replace references from global variables themselves.
  for (GlobalVariable &GV : M.globals()) {
    SmallVector<MDNode *, 4> MDs;
    GV.getMetadata(LLVMContext::MD_dbg, MDs);
    if (MDs.empty()) {
      continue;
    }
    GV.eraseMetadata(LLVMContext::MD_dbg);
    for (MDNode *MD : MDs) {
      auto NewDGVIt = NodesToReplace.find(MD);
      if (NewDGVIt != NodesToReplace.end()) {
        GV.addMetadata(LLVMContext::MD_dbg, *NewDGVIt->second);
      } else {
        // Keep anything that we don't have a replacement for intact.
        GV.addMetadata(LLVMContext::MD_dbg, *MD);
      }
    }
  }

  return !NodesToReplace.empty();
}

static bool processModule(Module &M) {
  DebugInfoFinder DIF;
  DIF.processModule(M);
  bool Changed = DIRewriter(M, DIF).run();
  LLVM_DEBUG(dbgs() << "IR Dump After DXIL Debug Info\n"; M.dump());
  return Changed;
}

PreservedAnalyses DXILDebugInfo::run(Module &M, ModuleAnalysisManager &MAM) {
  processModule(M);
  // FIXME: check if there is any analysis that we need to drop if we
  // change metadata.
  return PreservedAnalyses::all();
}

namespace {
class DXILDebugInfoLegacy : public ModulePass {
public:
  bool runOnModule(Module &M) override { return processModule(M); }

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
