# GitHub to GitLab Event Mapping Guide

This document maps the GitHub informer event catalog to the closest GitLab equivalents for this project.

The goal is to clarify which GitHub-style notifications can be matched directly with GitLab hooks, which ones can be approximated through GitLab CI pipeline context, and which ones require additional system hooks or custom integrations.

## Scope

This repository currently sends notifications from GitLab CI pipeline context and MR AI review jobs.

Current runtime coverage:

- GitLab CI pipeline source events handled in `GitLab_Cliq_Informer`
- MR diff AI review handled in `MRDiffAnalyzer`
- MR failure comments posted from the reusable CI template

This document is a design mapping for broader webhook support. It does not mean every mapped event is already implemented.

## Status Legend

| Status | Meaning |
| --- | --- |
| Supported now | Already covered by the current CI-driven notifier or MR review flow |
| Proposed webhook | Can be supported cleanly with GitLab project webhooks |
| Needs system hook or custom integration | No strong project webhook equivalent; requires system hooks, audit events, or API polling |
| No close equivalent | GitLab does not expose a strong direct match for the GitHub event/action pair |

## Recommended GitLab Event Set

To approach GitHub informer coverage, the next GitLab event layer should add these hooks:

- Push Hook
- Tag Push Hook
- Merge Request Hook
- Note Hook
- Issue Hook
- Pipeline Hook
- Job Hook
- Release Hook
- Deployment Hook
- Wiki Page Hook
- System Hooks or audit-event ingestion for admin/repository governance events

## Mapping Table

| GitHub Area | GitHub Actions / Examples | Closest GitLab Equivalent | Status | Notes |
| --- | --- | --- | --- | --- |
| Branch Protection Rule | created, deleted, edited | Protected branch changes via system hooks, audit events, or admin APIs | Needs system hook or custom integration | GitLab project CI variables do not expose this directly |
| Check Run / Check Suite | created, completed | Pipeline Hook, Job Hook | Proposed webhook | Best match for status-style automation events |
| Branch / Tag | branch created, deleted; tag created, deleted | Push Hook, Tag Push Hook | Proposed webhook | Current CI flow only sees pipeline execution, not full branch lifecycle |
| Deployment | deployment created, status changed | Deployment Hook, Pipeline Hook | Proposed webhook | Good fit when GitLab deployments/environments are used |
| Discussion | created, deleted, edited, pinned, answered, category changed | Note Hook plus discussion-related object metadata when available | Proposed webhook | Exact parity depends on GitLab discussion payload fields |
| Discussion Comment | created, edited, deleted | Note Hook | Proposed webhook | Merge request notes and issue notes map most closely |
| Fork | repository forked | System Hook, group/project events, or API polling | Needs system hook or custom integration | Not a normal project CI event |
| Wiki / Gollum | wiki page changed, footer/sidebar updated | Wiki Page Hook | Proposed webhook | Page-level details depend on GitLab payload |
| Issue | opened, closed, edited, reopened, labeled, assigned, milestoned | Issue Hook | Proposed webhook | Strong one-to-one family overall |
| Issue Comment | created, edited, deleted | Note Hook | Proposed webhook | Works for issue comments; PR comments map to MR notes |
| Label | label created, edited, deleted | System Hook, project API polling, or audit events | Needs system hook or custom integration | Labels are not usually emitted as a standard project event payload |
| Milestone | milestone created, edited, deleted | System Hook or API polling; issue/MR hooks for applied milestone changes | Needs system hook or custom integration | Milestone assignment is easy; milestone lifecycle is weaker |
| Page Build | page build created | Pipeline Hook / Job Hook if GitLab Pages pipeline is used | Proposed webhook | Treated more as CI execution than a standalone object event |
| Public Repository | repository made public | System Hook, audit events | Needs system hook or custom integration | Repository visibility changes are governance events |
| Pull Request | opened, edited, reopened, assigned, labeled, ready for review, synchronize, closed | Merge Request Hook | Proposed webhook | This is the strongest GitLab equivalent family |
| Pull Request Review | submitted, dismissed, edited | Note Hook plus MR approval/review metadata | Proposed webhook | GitLab review behavior is less separated than GitHub review objects |
| Pull Request Review Comment | created, edited, deleted | Note Hook on merge requests | Proposed webhook | Good functional match |
| Push | code pushed | Push Hook; CI `push` source | Supported now | Current notifier already supports CI `push` pipelines |
| Registry Package | package published | Package-related pipeline/job flow; possible package events via GitLab features | Proposed webhook | May need package registry specific integration depending on GitLab tier |
| Release | published, created, prereleased, released, edited, deleted | Release Hook | Proposed webhook | Good direct fit |
| Repository Dispatch | repository dispatch triggered | Pipeline Hook with API/trigger source, or custom trigger API handling | Supported now | Current CI notifier already handles `api` and `trigger` pipeline sources |
| Schedule | scheduled workflow | CI `schedule` source, Pipeline Hook | Supported now | Already covered in current notifier |
| Status | workflow status changed | Pipeline Hook, Job Hook | Proposed webhook | CI path partially covers this today |
| Watch | repository watched | No standard GitLab project webhook equivalent | No close equivalent | Usually outside GitLab project event scope |
| Workflow Dispatch | workflow manually triggered | CI `web`, `api`, `trigger`, `chat` sources | Supported now | Already represented by current GitLab CI sources |
| Error / Recovery Messages | workflow error, thread storage warning, AI review failure | Existing CI template, `MRDiffAnalyzer`, `GitLab_Cliq_Informer` | Supported now | Already implemented as pipeline log output, MR notes, and Cliq posts |
| AI Review Report | PR review report with status, summary, details | `MRDiffAnalyzer` MR notes and Cliq status notification | Supported now | Current implementation is MR-focused rather than webhook-driven |

## Current Coverage in This Repository

These GitLab event families are already covered today without adding a new webhook receiver:

- `push`
- `merge_request_event`
- `schedule`
- `api`
- `trigger`
- `web`
- `chat`
- `external`
- `external_pull_request_event`
- `parent_pipeline`
- `pipeline`
- `security_orchestration_policy`
- `ondemand_dast_scan`
- `ondemand_dast_validation`
- AI MR review failure and issue reporting

These come from GitLab CI predefined variables and the MR analysis job, not from a standalone webhook service.

## Suggested Implementation Order

If you want to expand this project toward GitHub-like breadth, the lowest-risk sequence is:

1. Add `Merge Request Hook` support.
2. Add `Note Hook` support.
3. Add `Issue Hook` support.
4. Add `Push Hook` and `Tag Push Hook` support.
5. Add `Pipeline Hook` and `Job Hook` support.
6. Add `Release Hook`, `Deployment Hook`, and `Wiki Page Hook` support.
7. Add system-hook or audit-event support for governance events like protected branches and visibility changes.

This order gives the fastest value because merge requests, notes, issues, and push activity are the closest GitLab equivalents to the GitHub informer patterns you shared.
