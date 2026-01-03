//===- bolt/Core/MCInstUtils.cpp ------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "bolt/Core/MCInstUtils.h"
#include "bolt/Core/BinaryBasicBlock.h"
#include "bolt/Core/BinaryFunction.h"

#include <type_traits>

using namespace llvm;
using namespace llvm::bolt;

// It is assumed in a few places that BinaryBasicBlock stores its instructions
// in a contiguous vector.
using BasicBlockStorageIsVector =
    std::is_same<BinaryBasicBlock::const_iterator,
                 std::vector<MCInst>::const_iterator>;
static_assert(BasicBlockStorageIsVector::value);

MCInstReference MCInstReference::get(const MCInst &Inst,
                                     const BinaryFunction &BF) {
  for (auto It = BF.instr_begin(), End = BF.instr_end(); It != End; ++It)
    if (&*It == &Inst)
      return MCInstReference(It);
  llvm_unreachable("Inst is not contained in BF");
}

uint64_t MCInstReference::computeAddress(const MCCodeEmitter *Emitter) const {
  assert(!empty() && "Taking instruction address by empty reference");

  const BinaryContext &BC = getFunction()->getBinaryContext();
  if (hasCFG()) {
    const uint64_t AddressOfBB =
        getFunction()->getAddress() + getBasicBlock()->getOffset();
    const MCInst *FirstInstInBB = &*getBasicBlock()->begin();
    const MCInst *ThisInst = &getMCInst();

    // Usage of plain 'const MCInst *' as iterators assumes the instructions
    // are stored in a vector, see BasicBlockStorageIsVector.
    const uint64_t OffsetInBB =
        BC.computeCodeSize(FirstInstInBB, ThisInst, Emitter);

    return AddressOfBB + OffsetInBB;
  }

  const uint64_t OffsetInBF = It.getOffset();

  return getFunction()->getAddress() + OffsetInBF;
}

raw_ostream &MCInstReference::print(raw_ostream &OS) const {
  if (empty()) {
    OS << "MCInstEmptyRef";
    return OS;
  }

  if (hasCFG()) {
    OS << "MCInstBBRef<";
    OS << "BB:" << getBasicBlock()->getName() << ":"
       << (&*It - &getBasicBlock()->front());
    OS << ">";
    return OS;
  }

  OS << "MCInstBFRef<";
  OS << "BF:" << getFunction()->getPrintName() << ":" << It.getOffset();
  OS << ">";
  return OS;
}
