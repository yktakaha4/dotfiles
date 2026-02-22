package mergejson_test

import (
	"reflect"
	"testing"

	"github.com/yktakaha4/dotfiles/tools/capytool/internal/mergejson"
)

func TestMerge_EmptyBase(t *testing.T) {
	dst := map[string]any{}
	src := map[string]any{"key": "value"}
	got := mergejson.Merge(dst, src)
	want := map[string]any{"key": "value"}
	if !reflect.DeepEqual(got, want) {
		t.Errorf("got %v, want %v", got, want)
	}
}

func TestMerge_EmptyOverride(t *testing.T) {
	dst := map[string]any{"key": "value"}
	src := map[string]any{}
	got := mergejson.Merge(dst, src)
	want := map[string]any{"key": "value"}
	if !reflect.DeepEqual(got, want) {
		t.Errorf("got %v, want %v", got, want)
	}
}

func TestMerge_ScalarOverride(t *testing.T) {
	dst := map[string]any{"key": "old"}
	src := map[string]any{"key": "new"}
	got := mergejson.Merge(dst, src)
	if got["key"] != "new" {
		t.Errorf("expected src to win, got %v", got["key"])
	}
}

func TestMerge_NestedObject(t *testing.T) {
	dst := map[string]any{
		"obj": map[string]any{"a": "1", "b": "old"},
	}
	src := map[string]any{
		"obj": map[string]any{"b": "new", "c": "3"},
	}
	got := mergejson.Merge(dst, src)
	obj, ok := got["obj"].(map[string]any)
	if !ok {
		t.Fatalf("expected map, got %T", got["obj"])
	}
	if obj["a"] != "1" {
		t.Errorf("expected a=1, got %v", obj["a"])
	}
	if obj["b"] != "new" {
		t.Errorf("expected b=new, got %v", obj["b"])
	}
	if obj["c"] != "3" {
		t.Errorf("expected c=3, got %v", obj["c"])
	}
}

func TestMerge_ArrayDeduplicate(t *testing.T) {
	dst := map[string]any{
		"permissions": map[string]any{
			"allow": []any{"Bash"},
		},
	}
	src := map[string]any{
		"permissions": map[string]any{
			"allow": []any{"Read", "Bash"},
		},
	}
	got := mergejson.Merge(dst, src)
	perms, ok := got["permissions"].(map[string]any)
	if !ok {
		t.Fatalf("expected map, got %T", got["permissions"])
	}
	allow, ok := perms["allow"].([]any)
	if !ok {
		t.Fatalf("expected slice, got %T", perms["allow"])
	}
	want := []any{"Bash", "Read"}
	if !reflect.DeepEqual(allow, want) {
		t.Errorf("got %v, want %v", allow, want)
	}
}

func TestMerge_ArrayNoDuplicates(t *testing.T) {
	dst := map[string]any{"list": []any{"a", "b"}}
	src := map[string]any{"list": []any{"c", "d"}}
	got := mergejson.Merge(dst, src)
	list, ok := got["list"].([]any)
	if !ok {
		t.Fatalf("expected slice, got %T", got["list"])
	}
	want := []any{"a", "b", "c", "d"}
	if !reflect.DeepEqual(list, want) {
		t.Errorf("got %v, want %v", list, want)
	}
}

func TestMerge_MismatchedTypes(t *testing.T) {
	// array in dst, scalar in src -> src (scalar) wins
	dst := map[string]any{"key": []any{"a"}}
	src := map[string]any{"key": "scalar"}
	got := mergejson.Merge(dst, src)
	if got["key"] != "scalar" {
		t.Errorf("expected scalar to win, got %v", got["key"])
	}
}

func TestMerge_DoesNotMutateDst(t *testing.T) {
	dst := map[string]any{"key": "original"}
	src := map[string]any{"key": "new"}
	_ = mergejson.Merge(dst, src)
	if dst["key"] != "original" {
		t.Errorf("Merge must not mutate dst, but got %v", dst["key"])
	}
}
