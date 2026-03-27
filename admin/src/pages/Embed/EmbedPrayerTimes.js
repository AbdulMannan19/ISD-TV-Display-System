import { useState, useEffect } from 'react';
import { supabase } from '../../supabase';
import './EmbedPrayerTimes.css';

const MASJIDAL_URL = 'https://masjidal.com/api/v1/time/range?masjid_id=O8L7ppA5';
const PRAYERS = ['fajr', 'zuhr', 'asr', 'maghrib', 'isha'];
const LABELS = { fajr: 'Fajr', zuhr: 'Dhuhr', asr: 'Asr', maghrib: 'Maghrib', isha: 'Isha' };

const to12 = (time) => {
  if (!time || time.includes('AM') || time.includes('PM')) return time || '-';
  const [h, m] = time.split(':').map(Number);
  const hour = h > 12 ? h - 12 : (h === 0 ? 12 : h);
  const period = h >= 12 ? 'PM' : 'AM';
  return `${hour}:${String(m).padStart(2, '0')} ${period}`;
};

export default function EmbedPrayerTimes() {
  const [times, setTimes] = useState({});
  const [hijriDate, setHijriDate] = useState('');
  const [sunrise, setSunrise] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchDb = async () => {
      const { data } = await supabase.from('prayer_times').select('*');
      if (data) {
        const map = {};
        data.forEach(row => { map[row.prayer] = row; });
        setTimes(map);
      }
    };

    const fetchMasjidal = async () => {
      try {
        const res = await fetch(MASJIDAL_URL);
        const json = await res.json();
        if (json.status === 'success' && json.data?.salah?.length) {
          const day = json.data.salah[0];
          const month = day.hijri_month || '';
          const dateParts = (day.hijri_date || '').split(',');
          const dayNum = dateParts[0]?.trim() || '';
          const year = dateParts[1]?.trim() || '';
          setHijriDate(year ? `${month} ${dayNum}, ${year}` : `${month} ${dayNum}`);
          setSunrise(day.sunrise || '');
        }
      } catch (_) { }
    };

    const init = async () => {
      await Promise.all([fetchDb(), fetchMasjidal()]);
      setLoading(false);
    };
    init();

    const channel = supabase.channel('embed-prayer-times')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'prayer_times' }, () => fetchDb())
      .subscribe();

    return () => { supabase.removeChannel(channel); };
  }, []);

  if (loading) return <div className="embed-loading">Loading...</div>;

  const now = new Date();
  const jummah = times['jummah'];

  return (
    <div className="embed-container">
      <div className="embed-card">
        <div className="embed-header">
          <div className="embed-title">Prayer Times</div>
          <div className="embed-subtitle">Islamic Society of Denton</div>
          <div className="embed-date">{formatDate(now)}</div>
          {hijriDate && <div className="embed-hijri">{hijriDate}</div>}
        </div>

        <table className="embed-table">
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
              if (!t) return null;
              const row = (
                <tr key={p}>
                  <td className="embed-prayer-name">{LABELS[p]}</td>
                  <td>{to12(t.adhan)}</td>
                  <td className="embed-iqamah">{to12(t.iqamah)}</td>
                </tr>
              );

              if (p === 'fajr' && sunrise) {
                return [
                  row,
                  <tr key="sunrise" className="embed-sunrise-row">
                    <td className="embed-prayer-name">Sunrise</td>
                    <td colSpan="2">{to12(sunrise)}</td>
                  </tr>
                ];
              }

              return row;
            })}
          </tbody>
        </table>

        {jummah && (
          <div className="embed-jummah">
            <span className="embed-jummah-label">Jumu'ah</span>
            <span className="embed-jummah-time">{to12(jummah.iqamah)}</span>
          </div>
        )}
      </div>
    </div>
  );
}

function formatDate(dt) {
  const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return `${days[dt.getDay()]}, ${months[dt.getMonth()]} ${dt.getDate()}, ${dt.getFullYear()}`;
}
