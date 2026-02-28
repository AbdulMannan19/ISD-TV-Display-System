import React, { useState, useEffect } from 'react';
import { supabase } from '../supabase';

export default function DailyInfo() {
  const [data, setData] = useState({});
  const [saving, setSaving] = useState(false);
  const [status, setStatus] = useState('');

  useEffect(() => {
    supabase.from('daily_info').select('*').single().then(({ data }) => {
      if (data) setData(data);
    });
  }, []);

  const handleChange = (field, value) => {
    setData(prev => ({ ...prev, [field]: value }));
  };

  const handleSave = async () => {
    setSaving(true);
    setStatus('');
    const { id, ...rest } = data;
    const { error } = await supabase.from('daily_info').update(rest).eq('id', 1);
    setSaving(false);
    setStatus(error ? error.message : 'Saved');
  };

  return (
    <div>
      <h2>Daily Info</h2>
      <div className="form-grid" style={{ marginTop: 16 }}>
        <div className="form-group">
          <label>English Date</label>
          <input type="date" value={data.english_date || ''} onChange={e => handleChange('english_date', e.target.value)} />
        </div>
        <div className="form-group">
          <label>Arabic / Hijri Date</label>
          <input type="text" value={data.arabic_date || ''} onChange={e => handleChange('arabic_date', e.target.value)} placeholder="e.g. Ramadan 11, 1447" />
        </div>
        <div className="form-group">
          <label>Sunrise</label>
          <input type="time" value={data.sunrise || ''} onChange={e => handleChange('sunrise', e.target.value)} />
        </div>
        <div className="form-group">
          <label>Sunset</label>
          <input type="time" value={data.sunset || ''} onChange={e => handleChange('sunset', e.target.value)} />
        </div>
      </div>
      <button className="save-btn" onClick={handleSave} disabled={saving}>
        {saving ? 'Saving...' : 'Save'}
      </button>
      {status && <div className="status">{status}</div>}
    </div>
  );
}
