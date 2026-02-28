import React, { useState, useEffect } from 'react';
import { supabase } from '../supabase';

const fields = [
  ['fajr', 'Fajr Start'], ['fajr_iqamah', 'Fajr Iqamah'],
  ['dhuhr', 'Dhuhr Start'], ['dhuhr_iqamah', 'Dhuhr Iqamah'],
  ['asr', 'Asr Start'], ['asr_iqamah', 'Asr Iqamah'],
  ['maghrib', 'Maghrib Start'], ['maghrib_iqamah', 'Maghrib Iqamah'],
  ['isha', 'Isha Start'], ['isha_iqamah', 'Isha Iqamah'],
  ['jumuah_1', "Jumu'ah 1"], ['jumuah_2', "Jumu'ah 2"],
];

export default function PrayerTimes() {
  const [data, setData] = useState({});
  const [saving, setSaving] = useState(false);
  const [status, setStatus] = useState('');

  useEffect(() => {
    supabase.from('prayer_times').select('*').single().then(({ data }) => {
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
    const { error } = await supabase.from('prayer_times').update(rest).eq('id', 1);
    setSaving(false);
    setStatus(error ? error.message : 'Saved');
  };

  return (
    <div>
      <h2>Prayer Times</h2>
      <div className="form-grid" style={{ marginTop: 16 }}>
        {fields.map(([key, label]) => (
          <div className="form-group" key={key}>
            <label>{label}</label>
            <input type="time" value={data[key] || ''} onChange={e => handleChange(key, e.target.value)} />
          </div>
        ))}
      </div>
      <button className="save-btn" onClick={handleSave} disabled={saving}>
        {saving ? 'Saving...' : 'Save'}
      </button>
      {status && <div className="status">{status}</div>}
    </div>
  );
}
