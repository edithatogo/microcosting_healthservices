package model

// Workbook is the top-level container for spreadsheet-like content.
type Workbook struct {
	Name   string            `json:"name,omitempty"`
	Sheets []Sheet           `json:"sheets,omitempty"`
	Meta   map[string]string `json:"meta,omitempty"`
}

// Sheet represents one tab within a workbook.
type Sheet struct {
	Name  string `json:"name"`
	Cells []Cell `json:"cells,omitempty"`
}

// CellType describes the currently stored value shape.
type CellType string

const (
	CellTypeBlank   CellType = "blank"
	CellTypeText    CellType = "text"
	CellTypeNumber  CellType = "number"
	CellTypeBool    CellType = "bool"
	CellTypeFormula CellType = "formula"
)

// Cell stores one raw cell payload without any formula evaluation.
type Cell struct {
	Ref     string   `json:"ref,omitempty"`
	Type    CellType `json:"type"`
	Text    *string  `json:"text,omitempty"`
	Number  *float64 `json:"number,omitempty"`
	Bool    *bool    `json:"bool,omitempty"`
	Formula *string  `json:"formula,omitempty"`
}

// Clone returns a shallow copy of the workbook metadata and slices.
func (w Workbook) Clone() Workbook {
	out := w
	if w.Sheets != nil {
		out.Sheets = append([]Sheet(nil), w.Sheets...)
	}
	if w.Meta != nil {
		out.Meta = make(map[string]string, len(w.Meta))
		for k, v := range w.Meta {
			out.Meta[k] = v
		}
	}
	return out
}
