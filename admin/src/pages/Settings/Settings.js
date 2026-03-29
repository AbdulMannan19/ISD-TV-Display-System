import { useState, useEffect } from 'react';
import { supabase } from '../../supabase';
import { DARK_THEMES, LIGHT_THEMES, ALL_THEMES } from '../../themes';
import './Settings.css';

const PREVIEW_PRAYERS = [
  { name: 'Fajr', adhan: '5:48 AM', iqamah: '6:05 AM' },
  { name: 'Dhuhr', adhan: '1:15 PM', iqamah: '1:30 PM' },
  { name: 'Asr', adhan: '4:42 PM', iqamah: '5:00 PM' },
  { name: 'Maghrib', adhan: '7:38 PM', iqamah: '7:45 PM' },
  { name: 'Isha', adhan: '9:10 PM', iqamah: '9:30 PM' },
];

function DisplayPreview({ theme }) {
  if (!theme) return null;
  const { bg, accent, accentBright, text, textMuted } = theme;

  return (
    <div className="display-preview" style={{ background: bg }}>
      {/* TV chrome bar */}
      <div className="dp-topbar">
        <span className="dp-org" style={{ color: accentBright }}>Islamic Society of Denton</span>
        <span className="dp-time" style={{ color: text }}>1:22 PM</span>
      </div>

      <div className="dp-body">
        {/* Prayer table */}
        <div className="dp-table" style={{ background: `${text}08`, border: `1px solid ${text}10` }}>
          <div className="dp-thead">
            <span className="dp-hcell" style={{ color: textMuted }}>Prayer</span>
            <span className="dp-hcell" style={{ color: textMuted }}>Starts</span>
            <span className="dp-hcell" style={{ color: accent }}>Iqamah</span>
          </div>
          <div className="dp-divider" style={{ background: `${text}15` }} />
          {PREVIEW_PRAYERS.map(p => (
            <div className="dp-row" key={p.name}>
              <span className="dp-name" style={{ color: text }}>{p.name}</span>
              <span className="dp-val" style={{ color: text }}>{p.adhan}</span>
              <span className="dp-val accent" style={{ color: accentBright }}>{p.iqamah}</span>
            </div>
          ))}
          <div className="dp-divider" style={{ background: `${text}15` }} />
          <div className="dp-jumah" style={{ color: accentBright, borderColor: `${accent}30`, background: `${accent}08` }}>
            JUMU'AH &nbsp;·&nbsp; 1:30 PM
          </div>
        </div>

        {/* Side panel */}
        <div className="dp-side" style={{ background: `${text}04`, border: `1px solid ${text}08` }}>
          <div className="dp-countdown-label" style={{ color: textMuted }}>NEXT IQAMAH IN</div>
          <div className="dp-countdown" style={{ color: accentBright }}>1:38</div>
          <div className="dp-sun">
            <span style={{ color: textMuted }}>☀ Sunrise<br /><b style={{ color: text }}>6:12 AM</b></span>
            <span style={{ color: textMuted }}>☀ Sunset<br /><b style={{ color: text }}>7:55 PM</b></span>
          </div>
        </div>
      </div>
    </div>
  );
}

export default function Settings() {
  const [savedThemeId, setSavedThemeId] = useState('');
  const [previewThemeId, setPreviewThemeId] = useState('');
  const [saving, setSaving] = useState(false);
  const [status, setStatus] = useState('');

  useEffect(() => { fetchSettings(); }, []);

  const fetchSettings = async () => {
    const { data } = await supabase.from('settings').select('*').eq('id', 1).single();
    if (data) {
      setSavedThemeId(data.theme_id);
      setPreviewThemeId(data.theme_id);
    }
  };

  const handleSave = async () => {
    if (!previewThemeId || previewThemeId === savedThemeId) return;
    setSaving(true);
    const { error } = await supabase.from('settings').upsert({ id: 1, theme_id: previewThemeId });
    setSaving(false);
    if (error) {
      setStatus('Error saving theme.');
    } else {
      setSavedThemeId(previewThemeId);
      setStatus('Theme applied to display!');
      setTimeout(() => setStatus(''), 3000);
    }
  };

  const previewTheme = ALL_THEMES.find(t => t.id === previewThemeId);
  const hasUnsaved = previewThemeId !== savedThemeId;

  const renderCard = (theme) => {
    const isSelected = previewThemeId === theme.id;
    const isSaved = savedThemeId === theme.id;
    return (
      <div
        key={theme.id}
        className={`theme-card ${isSelected ? 'selected' : ''} ${isSaved ? 'saved' : ''}`}
        onClick={() => setPreviewThemeId(theme.id)}
        title={theme.description}
      >
        <div className="theme-swatch" style={{ backgroundColor: theme.bg }}>
          <div className="theme-dot" style={{ backgroundColor: theme.accent }} />
          {isSaved && <span className="theme-live-badge">LIVE</span>}
        </div>
        <span className="theme-label">{theme.name}</span>
      </div>
    );
  };

  return (
    <div className="settings-page">
      <div className="page-header">
        <div>
          <h1 className="page-title">Display Settings</h1>
          <p className="page-subtitle">Pick a theme → preview it → save to apply to the TV.</p>
        </div>
      </div>

      {status && (
        <div className={`pt-status${status.includes('Error') ? ' error' : ''}`}>{status}</div>
      )}

      <div className="settings-layout">
        {/* ── Left: theme pickers ── */}
        <div className="settings-left">
          <div className="themes-container">
            <div className="theme-section">
              <h2 className="theme-section-title">Dark Themes</h2>
              <div className="theme-grid">{DARK_THEMES.map(renderCard)}</div>
            </div>
            <div className="theme-section">
              <h2 className="theme-section-title">Light / Alternate</h2>
              <div className="theme-grid">{LIGHT_THEMES.map(renderCard)}</div>
            </div>
          </div>
        </div>

        {/* ── Right: preview + save ── */}
        <div className="settings-right">
          <div className="preview-panel">
            <div className="preview-header">
              <div>
                <span className="preview-name" style={{ color: previewTheme?.accent }}>
                  {previewTheme?.name ?? '—'}
                </span>
                <span className="preview-desc">{previewTheme?.description}</span>
              </div>
              {hasUnsaved && <span className="preview-unsaved">Unsaved</span>}
            </div>

            <DisplayPreview theme={previewTheme} />

            <button
              className="save-btn"
              onClick={handleSave}
              disabled={saving || !hasUnsaved}
            >
              {saving ? 'Saving…' : hasUnsaved ? 'Save & Apply to Display' : '✓ Currently Applied'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
