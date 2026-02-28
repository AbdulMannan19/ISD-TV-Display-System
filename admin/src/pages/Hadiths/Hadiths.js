import { useState, useEffect } from 'react';
import { supabase } from '../../supabase';
import './Hadiths.css';

export default function Hadiths() {
  const [hadiths, setHadiths] = useState([]);
  const [editing, setEditing] = useState(null);
  const [draft, setDraft] = useState({ text: '', source: '' });
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    supabase.from('hadiths').select('*').order('id').then(({ data }) => {
      if (data) setHadiths(data);
    });
  }, []);

  const startEdit = (h) => { setEditing(h.id); setDraft({ text: h.text, source: h.source }); };
  const cancelEdit = () => { setEditing(null); };

  const handleSave = async (id) => {
    setSaving(true);
    await supabase.from('hadiths').update({ text: draft.text, source: draft.source }).eq('id', id);
    setHadiths(prev => prev.map(h => h.id === id ? { ...h, ...draft } : h));
    setEditing(null);
    setSaving(false);
  };

  return (
    <div>
      <h1 className="page-title">Hadith of the Day</h1>
      {hadiths.map(h => (
        <div className="hadith-card" key={h.id}>
          {editing === h.id ? (
            <>
              <div className="form-group" style={{ marginBottom: 12 }}>
                <label>Text</label>
                <textarea rows={4} value={draft.text} onChange={e => setDraft({ ...draft, text: e.target.value })} />
              </div>
              <div className="form-group" style={{ marginBottom: 16 }}>
                <label>Source</label>
                <input type="text" value={draft.source} onChange={e => setDraft({ ...draft, source: e.target.value })} />
              </div>
              <div style={{ display: 'flex', gap: 8, justifyContent: 'flex-end' }}>
                <button className="btn btn-outline btn-sm" onClick={cancelEdit}>Cancel</button>
                <button className="btn btn-primary btn-sm" onClick={() => handleSave(h.id)} disabled={saving}>
                  {saving ? 'Saving...' : 'Save'}
                </button>
              </div>
            </>
          ) : (
            <>
              <div className="hadith-label">Hadith {h.id}</div>
              <div className="hadith-text">"{h.text}"</div>
              <div className="hadith-source">— {h.source}</div>
              <button className="hadith-edit-btn" onClick={() => startEdit(h)} aria-label="Edit hadith">✏️</button>
            </>
          )}
        </div>
      ))}
    </div>
  );
}
