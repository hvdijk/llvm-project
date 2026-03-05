#!/usr/bin/env python3

import fileinput
import argparse
import re


di_keywords = (
    # Metadata from LangRef.rst
    "DICompileUnit",
    "DIFile",
    "DIBasicType",
    "DIFixedPointType",
    "DISubroutineType",
    "DIDerivedType",
    "DICompositeType",
    "DISubrange",
    "DISubrangeType",
    "DIEnumerator",
    "DITemplateTypeParameter",
    "DITemplateValueParameter",
    "DINamespace",
    "DIGlobalVariable",
    "DIGlobalVariableExpression",
    "DISubprogram",
    "DILexicalBlock",
    "DILexicalBlockFile",
    "DILocation",
    "DILocalVariable",
    "DIExpression",
    "DIAssignID",
    "DIArgList",
    "DIFlags",
    "DIObjCProperty",
    "DIImportedEntity",
    "DIMacro",
    "DIMacroFile",
    "DILabel",
    "DICommonBlock",
    "DIModule",
    "DIStringType",
    # Flags
    "DIFlagAllCallsDescribed",
    "DIFlagArtificial",
    "DIFlagEnumClass",
    "DIFlagExportSymbols",
    "DIFlagFwdDecl",
    "DIFlagLValueReference",
    "DIFlagNonTrivial",
    "DIFlagNoReturn",
    "DIFlagObjcClassComplete",
    "DIFlagObjectPointer",
    "DIFlagPrivate",
    "DIFlagProtected",
    "DIFlagPrototyped",
    "DIFlagPublic",
    "DIFlagRValueReference",
    "DIFlagStaticMember",
    "DIFlagTypePassByReference",
    "DIFlagTypePassByValue",
    "DIFlagVector",
)

# Compile and sort patterns by length to avoid matching DILexicalBlock
# in DILexicalBlockFile, for example.
di_patterns = tuple(
    sorted(((pat, re.compile(pat)) for pat in di_keywords), key=lambda p: -len(p[0]))
)


def processLines(lines):
    stat = {}
    for line in lines:
        line = line.strip()
        if line.startswith(";") or line.startswith("source_filename"):
            continue
        for key, pat in di_patterns:
            (line, count) = pat.subn("FOUND", line)
            if count > 0:
                stat[key] = stat.setdefault(key, 0) + count
    return stat


def main(args):
    stat = processLines(fileinput.input(args.files))
    for di, count in sorted(stat.items(), key=lambda kv: kv[0]):
        print(f"{di}: {count}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        prog="di_stat.py", description="Emit statistics for LLVM DebugInfo metadata"
    )
    parser.add_argument("files", nargs="*", help=".ll files to process")
    parser.add_argument("-o", dest="output", default="-", help="output file")
    args = parser.parse_args()
    main(args)
