#!/usr/bin/env bash
set -Eeuo pipefail

REPO="${OPENPDS_GITHUB_REPO:-Monotoba/openpds}"
MILESTONE="${OPENPDS_MILESTONE:-OpenPDS v0.2.0 — Architecture Foundation}"

log() {
    printf '\033[1;34m[openpds]\033[0m %s\n' "$*"
}

warn() {
    printf '\033[1;33m[warning]\033[0m %s\n' "$*" >&2
}

die() {
    printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2
    exit 1
}

command -v gh >/dev/null 2>&1 || die "GitHub CLI 'gh' is not installed."
gh auth status >/dev/null 2>&1 || die "GitHub CLI is not authenticated. Run: gh auth login"

if ! gh repo view "$REPO" >/dev/null 2>&1; then
    die "Repository $REPO is not accessible."
fi

if ! gh api "repos/$REPO/milestones?state=open" \
    --jq '.[].title' | grep -Fxq "$MILESTONE"; then
    die "Milestone not found: $MILESTONE"
fi

create_label() {
    local name="$1"
    local color="$2"
    local description="$3"

    if gh label list --repo "$REPO" --limit 200 \
        --json name --jq '.[].name' | grep -Fxq "$name"; then
        log "Label already exists: $name"
    else
        log "Creating label: $name"
        gh label create "$name" \
            --repo "$REPO" \
            --color "$color" \
            --description "$description"
    fi
}

issue_exists() {
    local title="$1"

    gh issue list \
        --repo "$REPO" \
        --state all \
        --limit 500 \
        --json title \
        --jq '.[].title' |
        grep -Fxq "$title"
}

create_issue() {
    local title="$1"
    local label="$2"
    local body="$3"

    if issue_exists "$title"; then
        warn "Issue already exists; skipping: $title"
        return
    fi

    log "Creating issue: $title"

    gh issue create \
        --repo "$REPO" \
        --title "$title" \
        --body "$body" \
        --milestone "$MILESTONE" \
        --label "$label" \
        --assignee "@me"
}

create_label \
    "architecture" \
    "5319E7" \
    "OpenPDS architecture and system organization"

create_label \
    "requirements" \
    "1D76DB" \
    "Requirements definition and traceability"

create_label \
    "governance" \
    "D4C5F9" \
    "Configuration management, change control, and project governance"

create_label \
    "verification" \
    "0E8A16" \
    "Verification, validation, testing, and acceptance criteria"

create_label \
    "documentation" \
    "0075CA" \
    "Standards documents, templates, and supporting documentation"

create_label \
    "tooling" \
    "FBCA04" \
    "OpenPDS CLI, schemas, validation, and automation"

create_label \
    "risk" \
    "B60205" \
    "Risk identification, analysis, mitigation, and tracking"

create_label \
    "ai-integration" \
    "7057FF" \
    "AI-assisted engineering requirements and safeguards"

create_issue \
    "Define OpenPDS scope and design principles" \
    "architecture" \
    "$(cat <<'EOF'
## Purpose

Define the scope, goals, non-goals, intended users, and governing principles of OpenPDS.

## Deliverables

- OpenPDS purpose statement
- Defined target users
- In-scope and out-of-scope activities
- Tool-independent design principles
- Offline-first principle
- Human and AI usability principles
- Evidence-oriented engineering principle

## Acceptance criteria

- Scope is explicit and unambiguous
- Non-goals are documented
- Principles can be applied to hardware, firmware, software, mechanical, manufacturing, and business work
- Content is incorporated into `OPENPDS-ARCH-001`

## Evidence expectations

Identify each major claim as Verified, Measured, Quoted, Calculated, Estimated, Assumed, Historical, or Unknown.
EOF
)"

create_issue \
    "Define product-development lifecycle phases and gates" \
    "architecture" \
    "$(cat <<'EOF'
## Purpose

Define the OpenPDS lifecycle from initial concept through end of life.

## Candidate lifecycle

Concept → Feasibility → Requirements → Architecture → Design → Prototype →
Verification → Release → Manufacturing → Support → End of Life

## Deliverables

- Lifecycle phase definitions
- Entry criteria for each phase
- Exit criteria for each phase
- Required artifacts
- Review gates
- Tailoring rules for small projects

## Acceptance criteria

- Every phase has clear inputs and outputs
- Gate criteria are objectively reviewable
- Lightweight projects can tailor the lifecycle without losing traceability
- Lifecycle is represented in the architecture specification
EOF
)"

create_issue \
    "Define OpenPDS document hierarchy and numbering" \
    "documentation" \
    "$(cat <<'EOF'
## Purpose

Create a consistent document taxonomy and identification system.

## Deliverables

- Document categories
- Document prefixes
- Numbering conventions
- Revision identifiers
- File-name conventions
- Supersession rules
- Cross-reference rules

## Example identifiers

- OPENPDS-ARCH-001
- OPENPDS-REQ-001
- OPENPDS-HW-001
- OPENPDS-FW-001
- OPENPDS-VER-001
- EDR-001

## Acceptance criteria

- Every standard and project artifact can be assigned a unique identifier
- Human-readable file names remain practical
- Renaming and revision rules are defined
- Identifiers remain stable across releases
EOF
)"

create_issue \
    "Define requirements and traceability model" \
    "requirements" \
    "$(cat <<'EOF'
## Purpose

Define how OpenPDS records, identifies, decomposes, verifies, and traces requirements.

## Deliverables

- Requirement record structure
- Requirement identifier convention
- Requirement types
- Parent-child relationships
- Source and rationale fields
- Verification method field
- Status and lifecycle fields
- Traceability matrix structure
- Change-impact rules

## Acceptance criteria

- Requirements can be traced to architecture, implementation, tests, and releases
- Orphaned requirements can be detected
- Unverified requirements can be reported
- The model supports hardware, firmware, software, mechanical, and business requirements
EOF
)"

create_issue \
    "Define Engineering Decision Record standard" \
    "architecture" \
    "$(cat <<'EOF'
## Purpose

Define the required content and lifecycle of Engineering Decision Records.

## Required EDR sections

- Problem
- Requirements
- Constraints
- Alternatives considered
- Tradeoffs
- Decision
- Evidence
- Confidence
- Risks
- Consequences
- Review triggers
- Supersession relationship

## Deliverables

- EDR standard
- Markdown template
- Machine-readable schema
- Example EDR

## Acceptance criteria

- Decisions can be reviewed independently of conversation history
- Rejected alternatives are preserved
- Assumptions and uncertainty are explicit
- Superseded decisions remain traceable
EOF
)"

create_issue \
    "Define evidence and confidence model" \
    "architecture" \
    "$(cat <<'EOF'
## Purpose

Formalize how OpenPDS distinguishes facts, measurements, calculations, estimates, assumptions, and unknowns.

## Evidence classes

- V — Verified
- M — Measured
- Q — Quoted
- C — Calculated
- E — Estimated
- A — Assumed
- H — Historical
- U — Unknown

## Deliverables

- Definitions for each evidence class
- Citation and source requirements
- Confidence representation
- Rules for converting one class to another
- Examples of acceptable and unacceptable usage

## Acceptance criteria

- Evidence classes are mutually understandable
- Evidence labels do not substitute for sources
- Unknowns and assumptions are surfaced rather than hidden
- Confidence is not represented as false precision
EOF
)"

create_issue \
    "Define risk-management framework" \
    "risk" \
    "$(cat <<'EOF'
## Purpose

Define a scalable risk-management process for OpenPDS projects.

## Deliverables

- Risk record structure
- Likelihood scale
- Impact scale
- Risk priority method
- Mitigation strategy
- Contingency strategy
- Risk owner
- Review interval
- Closure criteria
- Residual-risk recording

## Acceptance criteria

- Risks are linked to affected requirements or design decisions
- High risks require explicit treatment
- Residual risks remain visible
- Framework is usable for technical, manufacturing, supply-chain, financial, schedule, and safety risks
EOF
)"

create_issue \
    "Define configuration-management and change-control framework" \
    "governance" \
    "$(cat <<'EOF'
## Purpose

Define how OpenPDS controls versions, baselines, changes, releases, and authoritative source files.

## Deliverables

- Source-of-truth policy
- Baseline definitions
- Change request workflow
- Revision and release rules
- Approval requirements
- Compatibility classification
- Artifact manifest requirements
- Obsolete and superseded document handling

## Acceptance criteria

- Every released artifact has a known revision
- Changes can be traced to decisions and requirements
- Released files cannot be silently replaced
- Generated files are distinguishable from editable source files
EOF
)"

create_issue \
    "Define verification and validation framework" \
    "verification" \
    "$(cat <<'EOF'
## Purpose

Define how OpenPDS demonstrates that requirements are met and that the product is suitable for its intended use.

## Deliverables

- Definitions of verification and validation
- Verification methods
- Test-plan structure
- Test-case structure
- Acceptance criteria rules
- Test evidence requirements
- Deviation and failure handling
- Regression-test requirements
- Release-readiness criteria

## Acceptance criteria

- Every verifiable requirement identifies a method
- Test results are reproducible
- Deviations are documented
- Failed tests cannot be silently omitted
- Validation is distinct from design verification
EOF
)"

create_issue \
    "Define AI-assisted engineering requirements" \
    "ai-integration" \
    "$(cat <<'EOF'
## Purpose

Define how AI tools may assist OpenPDS projects without replacing evidence, verification, or engineering judgment.

## Deliverables

- AI role definitions
- Required human review points
- Source and citation requirements
- Hallucination safeguards
- Rules for generated calculations and code
- Rules for generated schematics and BOMs
- Confidentiality considerations
- Prompt and output retention guidance

## Acceptance criteria

- AI-produced claims are not treated as verified by default
- Generated artifacts require explicit review
- Unknowns and assumptions are preserved
- Source-of-truth documents remain authoritative
EOF
)"

create_issue \
    "Expand CLI validation for architecture documents" \
    "tooling" \
    "$(cat <<'EOF'
## Purpose

Extend the OpenPDS CLI so it can validate architecture and governance documents.

## Deliverables

- Required-document checks
- Document identifier validation
- Duplicate identifier detection
- File-name convention validation
- Required-heading validation
- Meaningful error reporting
- Unit and integration tests

## Acceptance criteria

- `openpds verify` reports missing required architecture artifacts
- Duplicate identifiers are rejected
- Errors identify the exact file and problem
- Valid projects continue to pass
EOF
)"

create_issue \
    "Add architecture documentation tests" \
    "tooling" \
    "$(cat <<'EOF'
## Purpose

Add automated checks for architecture documents, templates, and schemas.

## Deliverables

- Tests for required files
- Tests for document headings
- Tests for JSON schemas
- Tests for generated project structure
- Tests for release inclusion
- Coverage improvement for CLI and build modules

## Acceptance criteria

- CI fails when a required architecture file is missing
- CI fails for malformed schemas
- CLI commands have integration tests
- Test coverage increases from the initial 60 percent baseline
EOF
)"

log "Issue creation complete."

gh issue list \
    --repo "$REPO" \
    --milestone "$MILESTONE" \
    --limit 100
