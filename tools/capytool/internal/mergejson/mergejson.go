// Package mergejson provides utilities for deep-merging JSON objects.
package mergejson

import (
	"encoding/json"
	"fmt"
)

// Merge deep-merges src into dst and returns the result.
// Merging rules:
//   - Object (map) values are merged recursively.
//   - Array values are concatenated and then deduplicated (last-write-wins ordering).
//   - Scalar values from src overwrite those in dst.
func Merge(dst, src map[string]any) map[string]any {
	result := make(map[string]any, len(dst))
	for k, v := range dst {
		result[k] = v
	}

	for k, srcVal := range src {
		dstVal, exists := result[k]
		if !exists {
			result[k] = srcVal
			continue
		}

		dstMap, dstIsMap := dstVal.(map[string]any)
		srcMap, srcIsMap := srcVal.(map[string]any)
		if dstIsMap && srcIsMap {
			result[k] = Merge(dstMap, srcMap)
			continue
		}

		dstArr, dstIsArr := dstVal.([]any)
		srcArr, srcIsArr := srcVal.([]any)
		if dstIsArr && srcIsArr {
			combined := append(dstArr, srcArr...)
			result[k] = deduplicate(combined)
			continue
		}

		// Scalar or mismatched type: src wins.
		result[k] = srcVal
	}

	return result
}

// deduplicate removes duplicate elements from a slice while preserving order.
// Equality is determined by comparing JSON representations.
func deduplicate(arr []any) []any {
	seen := make(map[string]struct{}, len(arr))
	out := make([]any, 0, len(arr))
	for _, elem := range arr {
		key, err := jsonKey(elem)
		if err != nil {
			// If we can't serialise the element, keep it to avoid silent data loss.
			out = append(out, elem)
			continue
		}
		if _, ok := seen[key]; ok {
			continue
		}
		seen[key] = struct{}{}
		out = append(out, elem)
	}
	return out
}

// jsonKey returns a canonical JSON string for use as a map key.
func jsonKey(v any) (string, error) {
	b, err := json.Marshal(v)
	if err != nil {
		return "", fmt.Errorf("mergejson: marshal: %w", err)
	}
	return string(b), nil
}
