import React, { useState, useEffect } from 'react';
import { supabase } from '../supabase';

export default function Hadiths() {
  const [hadiths, setHadiths] = useState([]);
  const [text, setText] = useState('');
  const [source, setSource] = useState('');

  const fetchHadiths = async () => {
    const { data } = await supabase.from('hadiths').select('*').order('id');
    if (data) setHadiths(data);
  };

  useEffect(() => { fetchHadiths(); }, []);

  const handleAdd = async (e) => {
    e.preventDefault();
    if (!text.trim() || !source.trim()) return;
    await supabase.from('hadiths').insert({ text: text.trim(), source: source.trim() });
    setText('');
    setSource('');
    fetchHadiths();
  };

  const toggleActive = async (h) => {
    await supabase.from('hadiths').update({ is_active: !h.is_active }).eq('id', h.id);
    fetchHadiths();
  };

  const deleteHadith = async (h) => {
    await supabase.from('hadiths').delete().eq('id', h.id);
    fetchHadiths();
  };

  return (
    <div>
      <h2>Hadiths</h2>
      <form onSubmit={handleAdd} style={{ marginTop: 16, marginBottom: 20 }}>
        <div className="form-grid">
          <div className="form-group form-full">
            <label>Hadith Text</label>
            <textarea value={text} onChange={e => setText(e.target.value)} rows={3} style={{ padding: 8, border: '1px solid #ddd', borderRadius: 6, fontSize: '1rem', resize: 'vertical' }} required />
          </div>
          <div className="form-group">
            <label>Source</label>
            <input type="text" value={source} onChange={e => setSource(e.target.value)} placeholder="e.g. Tirmidhi" required />
          </div>
          <div className="form-group" style={{ justifyContent: 'flex-end' }}>
            <button className="save-btn" type="submit" style={{ margin: 0 }}>Add Hadith</button>
          </div>
        </div>
      </form>
      {hadiths.map(h => (
        <div className="slide-card" key={h.id} style={{ flexDirection: 'column', alignItems: 'flex-start' }}>
          <div style={{ fontSize: '0.95rem' }}>"{h.text}"</div>
          <div style={{ fontSize: '0.85rem', color: '#666', marginTop: 4 }}>— {h.source}</div>
          <div className="slide-actions" style={{ marginTop: 8 }}>
            <button onClick={() => toggleActive(h)}>
              {h.is_active ? 'Disable' : 'Enable'}
            </button>
            <button className="delete" onClick={() => deleteHadith(h)}>Delete</button>
          </div>
        </div>
      ))}
      {hadiths.length === 0 && <p>No hadiths yet. Add one above.</p>}
    </div>
  );
}
