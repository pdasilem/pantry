package config

import (
	"path/filepath"
	"testing"
)

func TestGetUniamHome(t *testing.T) {
	// Test default
	home := GetUniamHome()
	if home == "" {
		t.Error("GetUniamHome() should not return empty string")
	}

	// Test with environment variable
	t.Setenv("UNIAM_HOME", "/test/uniam")

	home = GetUniamHome()
	if home != "/test/uniam" {
		t.Errorf("GetUniamHome() = %q, want %q", home, "/test/uniam")
	}
}

func TestLoadConfig(t *testing.T) {
	// Test with non-existent file (should return defaults)
	cfg, err := LoadConfig("/nonexistent/config.yaml")
	if err != nil {
		t.Errorf("LoadConfig() error = %v, want nil", err)
	}

	if cfg == nil {
		t.Fatal("LoadConfig() returned nil config")
	}

	//nolint:goconst
	if cfg.Embedding.Provider != "ollama" {
		t.Errorf("LoadConfig() default provider = %q, want %q", cfg.Embedding.Provider, "ollama")
	}
}

func TestGetDefaultConfigTemplate(t *testing.T) {
	template := GetDefaultConfigTemplate()
	if template == "" {
		t.Error("GetDefaultConfigTemplate() should not return empty string")
	}

	if len(template) < 100 {
		t.Error("GetDefaultConfigTemplate() should return substantial template")
	}
}

func TestSaveConfig(t *testing.T) {
	tmpDir := t.TempDir()
	configPath := filepath.Join(tmpDir, "config.yaml")

	cfg := &Config{
		Embedding: EmbeddingConfig{
			Provider: "ollama",
			Model:    "test-model",
		},
	}

	err := SaveConfig(configPath, cfg)
	if err != nil {
		t.Errorf("SaveConfig() error = %v", err)
	}

	// Verify it can be loaded back
	loaded, err := LoadConfig(configPath)
	if err != nil {
		t.Errorf("LoadConfig() after SaveConfig error = %v", err)
	}

	if loaded.Embedding.Model != "test-model" {
		t.Errorf("LoadConfig() Model = %q, want %q", loaded.Embedding.Model, "test-model")
	}
}
