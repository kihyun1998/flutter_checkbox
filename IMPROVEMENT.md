# API 개선 문서

## 개요

기존 `CustomCheckbox` 하나로 모든 역할을 하던 구조를 **두 개의 위젯**으로 분리한다.

- **FlutterCheckbox** — 체크 박스 그래픽만 렌더링
- **FlutterCheckboxTile** — 체크박스 + 라벨 + 타일 컨테이너

---

## FlutterCheckbox

순수하게 체크 박스 그래픽과 상태만 담당하는 위젯.
라벨 없음, 터치 영역 = 박스 크기.

### Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `value` | `bool` | required | 체크 여부 |
| `onChanged` | `ValueChanged<bool>?` | `null` | 값 변경 콜백. null이면 비대화형 |
| `size` | `double` | `24` | 박스 너비/높이 (px) |
| `shape` | `CheckboxShape` | `rectangle` | 박스 모양 (rectangle / circle) |
| `activeColor` | `Color?` | `ColorScheme.primary` | 체크 시 배경색 |
| `inactiveColor` | `Color?` | `Colors.transparent` | 미체크 시 배경색 |
| `checkColor` | `Color?` | `Colors.white` | 체크마크 색상 |
| `borderColor` | `Color?` | `ColorScheme.outline` | 테두리 색상 |
| `borderWidth` | `double` | `2` | 테두리 두께 |
| `borderRadius` | `double` | `4` | 모서리 둥글기 (rectangle만 적용) |
| `checkStrokeWidth` | `double` | `2.5` | 체크마크 선 두께 |
| `animationDuration` | `Duration` | `200ms` | 체크 애니메이션 시간 |
| `animationCurve` | `Curve` | `Curves.easeInOut` | 체크 애니메이션 곡선 |
| `enabled` | `bool` | `true` | 활성화 여부 |
| `focusNode` | `FocusNode?` | `null` | 포커스 노드 |
| `autofocus` | `bool` | `false` | 자동 포커스 |
| `mouseCursor` | `MouseCursor?` | `SystemMouseCursors.click` | 마우스 커서 |

---

## FlutterCheckboxTile

체크박스 + 라벨을 하나의 타일로 감싸는 위젯.
터치 영역이 타일 전체로 확장되며, 배경/테두리/인터랙션 피드백을 포함한다.

### Properties

#### 값 & 콜백

| Property | Type | Default | Description |
|---|---|---|---|
| `value` | `bool` | required | 체크 여부 |
| `onChanged` | `ValueChanged<bool>?` | `null` | 값 변경 콜백 |

#### 체크박스 스타일

| Property | Type | Default | Description |
|---|---|---|---|
| `checkboxStyle` | `CheckboxStyle` | `CheckboxStyle()` | FlutterCheckbox의 모든 스타일을 담은 객체 |

#### 라벨

| Property | Type | Default | Description |
|---|---|---|---|
| `label` | `String?` | `null` | 텍스트 라벨 |
| `labelWidget` | `Widget?` | `null` | 커스텀 라벨 위젯 (label과 동시 사용 불가) |
| `labelStyle` | `TextStyle?` | `null` | 라벨 텍스트 스타일 |
| `gap` | `double` | `8` | 체크박스-라벨 간격 |

#### 타일 배경

| Property | Type | Default | Description |
|---|---|---|---|
| `backgroundColor` | `Color?` | `null` | 타일 기본 배경색 |
| `selectedColor` | `Color?` | `null` | 체크 시 타일 배경색 |
| `disabledColor` | `Color?` | `null` | 비활성 시 타일 배경색 |

#### 타일 테두리

| Property | Type | Default | Description |
|---|---|---|---|
| `tileBorderRadius` | `BorderRadius?` | `null` | 타일 모서리 둥글기 |
| `tileBorderColor` | `Color?` | `null` | 타일 테두리 색상 |
| `tileBorderWidth` | `double?` | `null` | 타일 테두리 두께 |
| `tileBorderSide` | `BorderSide?` | `null` | 타일 테두리 세밀 제어 (설정 시 color/width 무시) |

#### 인터랙션

| Property | Type | Default | Description |
|---|---|---|---|
| `hoverColor` | `Color?` | `primary.withOpacity(0.08)` | 마우스 hover 시 타일 오버레이 |
| `splashColor` | `Color?` | `primary.withOpacity(0.12)` | 탭 시 ripple 색상 |
| `highlightColor` | `Color?` | `null` | 탭 유지 시 하이라이트 색상 |
| `focusColor` | `Color?` | `primary.withOpacity(0.12)` | 포커스 시 타일 오버레이 |

#### 레이아웃

| Property | Type | Default | Description |
|---|---|---|---|
| `padding` | `EdgeInsetsGeometry?` | `null` | 타일 내부 여백 |
| `margin` | `EdgeInsetsGeometry?` | `null` | 타일 외부 여백 |
| `constraints` | `BoxConstraints?` | `null` | 타일 크기 제약 |

#### 그림자

| Property | Type | Default | Description |
|---|---|---|---|
| `elevation` | `double` | `0` | 타일 그림자 높이 |

#### 기타

| Property | Type | Default | Description |
|---|---|---|---|
| `mouseCursor` | `MouseCursor?` | `SystemMouseCursors.click` | 마우스 커서 |
| `enabled` | `bool` | `true` | 활성화 여부 |
| `focusNode` | `FocusNode?` | `null` | 포커스 노드 |
| `autofocus` | `bool` | `false` | 자동 포커스 |

---

## 마이그레이션

| 기존 | 변경 후 |
|---|---|
| `CustomCheckbox(value, onChanged)` | `FlutterCheckbox(value, onChanged)` |
| `CustomCheckbox(value, label, onChanged)` | `FlutterCheckboxTile(value, label, onChanged)` |
| `CustomCheckbox(value, labelWidget, onChanged)` | `FlutterCheckboxTile(value, labelWidget, onChanged)` |
| `CheckboxStyle` | `CheckboxStyle` (체크박스 그래픽 스타일만 유지) |
