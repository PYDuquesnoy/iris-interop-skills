#!/usr/bin/env python3
"""SessionStart bootstrap for iris-interop-skills.

Proactively injects the core interop conventions at session start so a weak model has them WITHOUT
having to choose to call the Skill tool (observed: a Haiku run never invoked any skill despite them
being installed + instructed). This is the "make it available up front" half; the PreToolUse gate
(interop_conformance_gate) is the "make it binding" half.
"""
import sys, json

MSG = (
    "iris-interop-skills active. For ANY IRIS Interoperability work, BEFORE writing classes: load "
    "Skill(iris-interop-skills:interop) (router) + Skill(iris-interop-skills:component-map) + "
    "Skill(iris-interop-skills:tdd) — or hand the whole component to the interop-builder agent. "
    "Non-negotiable conventions (a PreToolUse gate will BLOCK violations): "
    "(1) name classes <Package>.<Tipo>.<Name> with Tipo in BS/BP/BO/DT/RUL/MSG — never "
    "Service/Operation/Process/Transform/Message; "
    "(2) a Business Service/Operation Extends Ens.BusinessService/Ens.BusinessOperation with "
    "Parameter ADAPTER=\"...\" — never Extend the adapter directly; "
    "(3) route with a MessageRouter + business rule, not a hand BusinessProcess OnRequest; "
    "(4) reach IRIS ONLY through the MCP (iris_doc/iris_compile/iris_test) — never iris.exe / "
    "iris session / $SYSTEM.OBJ.Load / $SYSTEM.OBJ.Compile; "
    "(5) TDD: a component is done only when its %UnitTest.TestProduction actually runs GREEN via "
    "iris_test (NO_TESTS_FOUND means compile the test first and pass the exact class name)."
)


def main():
    # SessionStart payload is read (and ignored) so stdin doesn't block the wrapper.
    try:
        json.load(sys.stdin)
    except Exception:
        pass
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "SessionStart", "additionalContext": MSG}}))


if __name__ == "__main__":
    main()
