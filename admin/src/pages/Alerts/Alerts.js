import { useState, useEffect } from 'react';
import { supabase } from '../../supabase';
import './Alerts.css';

const TrashIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" width="14" height="14">
    <polyline points="3 6 5 6 21 6" /><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
  </svg>
);

const EditIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" width="14" height="14">
    <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" />
    <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
  </svg>
);

const InfoIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" width="16" height="16">
    <circle cx="12" cy="12" r="10" /><line x1="12" y1="16" x2="12" y2="12" /><line x1="12" y1="8" x2="12.01" y2="8" />
  </svg>
);

const toLocalInput = (iso) => {
  if (!iso) return '';
  const d = new Date(iso);
  const pad = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
};

const defaultStart = () => toLocalInput(new Date().toISOString());
const defaultEnd = () => toLocalInput(new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString());

const formatDt = (iso) => {
  if (!iso) return '-';
  const d = new Date(iso);
  const pad = (n) => String(n).padStart(2, '0');
  const mon = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  const h = d.getHours() % 12 || 12;
  const ampm = d.getHours() >= 12 ? 'PM' : 'AM';
  return `${mon[d.getMonth()]} ${d.getDate()}, ${h}:${pad(d.getMinutes())} ${ampm}`;
};

export default function Alerts() {
  const [alerts, setAlerts] = useState([]);
  const [text, setText] = useState('');
  const [startTime, setStartTime] = useState(defaultStart);
  const [endTime, setEndTime] = useState(defaultEnd);
  const [loading, setLoading] = useState(true);
  const [sending, setSending] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [editStart, setEditStart] = useState('');
  const [editEnd, setEditEnd] = useState('');

  const fetchAlerts = async () => {
    const { data } = await supabase
      .from('alerts')
      .select('*')
      .order('created_at', { ascending: false });
    if (data) setAlerts(data);
    setLoading(false);
  };

  useEffect(() => { fetchAlerts(); }, []);

  const handleAdd = async (e) => {
    e.preventDefault();
    if (!text.trim()) return;
    setSending(true);
    const { error } = await supabase.from('alerts').insert({
      text: text.trim(),
      start_time: new Date(startTime).toISOString(),
      end_time: new Date(endTime).toISOString(),
    });
    if (error) {
      alert('Error adding alert: ' + error.message);
    } else {
      setText('');
      setStartTime(defaultStart());
      setEndTime(defaultEnd());
      fetchAlerts();
    }
    setSending(false);
  };

  const handleDelete = async (id) => {
    const { error } = await supabase.from('alerts').delete().eq('id', id);
    if (!error) fetchAlerts();
  };

  const handleEditSave = async (id) => {
    const { error } = await supabase.from('alerts').update({
      start_time: new Date(editStart).toISOString(),
      end_time: new Date(editEnd).toISOString(),
    }).eq('id', id);
    if (!error) { setEditingId(null); fetchAlerts(); }
  };

  const startEdit = (a) => {
    setEditingId(a.id);
    setEditStart(toLocalInput(a.start_time));
    setEditEnd(toLocalInput(a.end_time));
  };

  const getStatus = (a) => {
    const now = new Date();
    const start = new Date(a.start_time);
    const end = new Date(a.end_time);
    if (now < start) return 'scheduled';
    if (now >= start && now < end) return 'active';
    return 'expired';
  };

  if (loading) return <div className="loading">Loading...</div>;

  return (
    <div>
      <div className="page-header">
        <div>
          <h1 className="page-title">Alerts</h1>
          <p className="page-subtitle">Send scrolling alerts to the display screens</p>
        </div>
      </div>

      <div className="alerts-info">
        <InfoIcon />
        <span>Alerts appear as a red scrolling bar on all screens except silence and slides. Set start and end times to schedule when they show.</span>
      </div>

      <form className="alerts-form-grid" onSubmit={handleAdd}>
        <input
          className="alerts-input"
          type="text"
          placeholder="Type alert message..."
          value={text}
          onChange={e => setText(e.target.value)}
          style={{ gridColumn: '1 / -1' }}
        />
        <label className="alerts-label">
          <span>Start</span>
          <input type="datetime-local" className="alerts-input" value={startTime} onChange={e => setStartTime(e.target.value)} />
        </label>
        <label className="alerts-label">
          <span>End</span>
          <input type="datetime-local" className="alerts-input" value={endTime} onChange={e => setEndTime(e.target.value)} />
        </label>
        <button className="btn btn-green" type="submit" disabled={sending} style={{ alignSelf: 'end' }}>
          {sending ? 'Sending...' : 'Send Alert'}
        </button>
      </form>

      {alerts.length === 0 ? (
        <div className="alerts-empty">No alerts</div>
      ) : (
        <div className="alerts-list">
          {alerts.map(a => {
            const status = getStatus(a);
            return (
              <div key={a.id} className={`alert-card alert-${status}`}>
                <div className="alert-content">
                  <span className="alert-text">{a.text}</span>
                  {editingId === a.id ? (
                    <div className="alert-edit-row">
                      <input type="datetime-local" className="alerts-input-sm" value={editStart} onChange={e => setEditStart(e.target.value)} />
                      <span>to</span>
                      <input type="datetime-local" className="alerts-input-sm" value={editEnd} onChange={e => setEditEnd(e.target.value)} />
                      <button className="btn btn-green btn-sm" onClick={() => handleEditSave(a.id)}>Save</button>
                      <button className="btn btn-sm" onClick={() => setEditingId(null)}>Cancel</button>
                    </div>
                  ) : (
                    <span className="alert-meta">{formatDt(a.start_time)} → {formatDt(a.end_time)}</span>
                  )}
                </div>
                <span className={`alert-badge alert-badge-${status}`}>{status}</span>
                <button className="alert-action-btn" onClick={() => startEdit(a)} title="Edit times"><EditIcon /></button>
                <button className="alert-delete" onClick={() => handleDelete(a.id)} title="Delete alert"><TrashIcon /></button>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
