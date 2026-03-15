import { useState, useEffect } from 'react';
import { supabase } from '../../supabase';
import './PrayerTimes.css';

const ClockIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" width="16" height="16">
    <circle cx="12" cy="12" r="10" /><polyline points="12 6 12 12 16 14" />
  </svg>
);

const SaveIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" width="14" height="14">
    <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1-2 2h11l4 4v9a2 2 0 0 1-2 2z" />
    <polyline points="17 21 17 13 7 13 7 21" /><polyline points="7 3 7 8 15 8" />
  </svg>
);

const PRAYERS = ['fajr', 'zuhr', 'asr', 'maghrib', 'isha'];
const LABELS = { fajr: 'Fajr', zuhr: 'Dhuhr', asr: 'Asr', maghrib: 'Maghrib', isha: 'Isha' };
const JUMMAH = ['jummah1', 'jummah2'];
const JUMMAH_LABELS = { jummah1: "Jumu'ah 1", jummah2: "Jumu'ah 2" };
const NON_EDITABLE = ['maghrib'];

export default function PrayerTimes() {
  const [times, setTimes] = useState({});
  const [editing, setEditing] = useState({});
  const [saving, setSaving] = useState(false);
  const [status, setStatus] = useState('');
  const [loading, setLoading] = useState(true);

  const fetchTimes = async () => {
    const { data } = await supabase.from('prayer_times').select('*');
    if (data) {
      const map = {};
      data.forEach(row => { map[row.prayer] = { adhan: row.adhan, iqamah: row.iqamah }; });
      setTimes(map);
      setEditing(Object.fromEntries(
        data.filter(r => !NON_EDITABLE.includes(r.prayer))
            .map(r => [r.prayer, r.iqamah])
      ));
    }
    setLoading(false);
  };

  useEffect(() => { fetchTimes(); }, []);

  const handleSave = async () => {
    setSaving(true);
    setStatus('');
    const updates = Object.entries(editing).map(([prayer, iqamah]) =>
      supabase.from('prayer_times').update({ iqamah }).eq('prayer', prayer)
    );
    const results = await Promise.all(updates);
    const err = results.find(r => r.error);
    if (err) {
      setStatus('Error saving: ' + err.error.message);
    } else {
      setStatus('Times updated');
      fetchTimes();
    }
    setSaving(false);
    setTimeout(() => setStatus(''), 3000);
  };

  const to12 = (time) => {
    if (!time || time.includes('AM') || time.includes('PM')) return time || '-';
    const [h, m] = time.split(':').map(Number);
    const hour = h > 12 ? h - 12 : (h === 0 ? 12 : h);
    const period = h >= 12 ? 'PM' : 'AM';
    return `${hour}:${String(m).padStart(2, '0')} ${period}`;
  };

  if (loading) return <div className="loading">Loading...</div>;

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">Prayer Times</h1>
          <p className="page-subtitle">View adhan times and manage iqamah times</p>
        </div>
        <button className="btn btn-green" onClick={handleSave} disabled={saving}>
          <SaveIcon /> {saving ? 'Saving...' : 'Save Changes'}
        </button>
      </div>

      {status && (
        <div className={`pt-status${status.startsWith('Error') ? ' error' : ''}`}>{status}</div>
      )}

      <div className="pt-info">
        <ClockIcon />
        <span>Adhan times are fetched automatically from the Aladhan API. Maghrib iqamah is always adhan + 10 min.</span>
      </div>

      <div className="pt-table-wrap">
        <table className="pt-table">
          <thead>
            <tr>
              <th>Prayer</th>
              <th>Adhan</th>
              <th>Iqamah</th>
            </tr>
          </thead>
          <tbody>
            {PRAYERS.map(p => {
              const t = times[p];
              const isEditable = !NON_EDITABLE.includes(p);
              return (
                <tr key={p}>
                  <td className="pt-prayer-name">{LABELS[p]}</td>
                  <td className="pt-time">{t ? to12(t.adhan) : '-'}</td>
                  <td className="pt-time">
                    {isEditable ? (
                      <input
                        type="time"
                        value={editing[p] || ''}
                        onChange={e => setEditing({ ...editing, [p]: e.target.value })}
                        className="pt-input"
                      />
                    ) : (
                      <span className="pt-auto">{t ? to12(t.iqamah) : '-'} <span className="pt-auto-badge">Auto</span></span>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      <div className="pt-table-wrap" style={{ marginTop: '20px' }}>
        <table className="pt-table">
          <thead>
            <tr>
              <th>Jumu'ah</th>
              <th>Time</th>
            </tr>
          </thead>
          <tbody>
            {JUMMAH.map(j => (
              <tr key={j}>
                <td className="pt-prayer-name">{JUMMAH_LABELS[j]}</td>
                <td className="pt-time">
                  <input
                    type="time"
                    value={editing[j] || ''}
                    onChange={e => setEditing({ ...editing, [j]: e.target.value })}
                    className="pt-input"
                  />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
