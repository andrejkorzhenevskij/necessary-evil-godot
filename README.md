# Necessary Evil (Godot Narrative MVP)

## Overview

Necessary Evil — narrative vertical slice, построенный в Godot.

Проект демонстрирует:

* state management между сценами;
* data-driven narrative flow;
* результативную систему на основе решений игрока;
* UI-driven storytelling;
* сохранение метапрогрессии между прохождениями.

Проект является MVP / vertical slice и не претендует на полноту контента.

## Main Flow

IntroScreen
→ TitleScreen
→ GameplayScreen
→ SurgeryLayer
→ SnapshotScreen
→ FinalScreen

GameplayScreen может возвращать игрока в дополнительные narrative segments в зависимости от контекста прохождения.

## State Management

Основное состояние хранится в autoload GameState.

GameState отвечает за:

* текущую фазу прохождения;
* распределение ресурсов;
* outcome calculation;
* badges;
* dossier fragments;
* snapshot context;
* replay state.

## Narrative Architecture

Narrative content хранится в narrative/.

GameplayScreen намеренно совмещает narrative playback, routing и presentation logic.

Для MVP это сознательное решение: задача проекта — показать полный вертикальный срез игрового цикла, а не финальную production-архитектуру.

## Meta Progression

reset_run() очищает состояние текущего прохождения, но сохраняет открытые dossier fragments.

Это сделано намеренно и является частью метапрогрессии проекта.

## Development Notes

В проекте присутствуют debug shortcuts и дополнительные диагностические сообщения, используемые для проверки narrative pipeline и result calculation.


F1/F2/F3 сохранены как ранние прототипы и не используются в основном gameplay flow.
