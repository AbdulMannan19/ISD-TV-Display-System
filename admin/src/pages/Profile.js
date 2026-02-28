import React, { useState, useEffect } from 'react';
import { supabase } from '../supabase';

export default function Profile() {
  const [editing, setEditing] = useState(false);
  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');
  const [saving, setSaving] = useState(false);
  const [status, setStatus] = useState('');
  const [email, setEmail] = useState('');

  useEffect(() => {
    supabase.auth.getUser().then(({ data: { user } }) => {
      if (user) setEmail(user.email);
    });
  }, []);

  const handleSave = async () => {
    setStatus('');
    if (password.length < 6) { setStatus('Password must be at least 6 characters'); return; }
    if (password !== confirm) { setStatus('Passwords do not match'); return; }
    setSaving(true);
    const { error } = await supabase.auth.updateUser({ password });
    setSaving(false);
    if (error) {
      setStatus(error.message);
    } else {
      setStatus('Password updated');
      setEditing(false);
      setPassword('');
      setConfirm('');
    }
  };

  const cancelEdit = () => {
    setEditing(false);
    setPassword('');
    setConfirm('');
    setStatus('');
  };

  return (
    <div>
      <h1 className="page-title">Profile</h1>
      <div className="hadith-display-card" style={{ maxWidth: 480, marginBottom: 20 }}>
        <div className="hadith-label">Email</div>
        <div style={{ fontSize: '1rem', color: 'var(--text)' }}>{email}</div>
      </div>
      <div className="hadith-display-card" style={{ maxWidth: 480 }}>
        {editing ? (
          <>
            <div className="form-group" style={{ marginBottom: 12 }}>
              <label>New Password</label>
              <input type="password" value={password} onChange={e => setPassword(e.target.value)} placeholder="Min 6 characters" />
            </div>
            <div className="form-group" style={{ marginBottom: 16 }}>
              <label>Confirm Password</label>
              <input type="password" value={confirm} onChange={e => setConfirm(e.target.value)} placeholder="Re-enter password" />
            </div>
            {status && <div style={{ fontSize: '0.85rem', color: status === 'Password updated' ? 'var(--success)' : 'var(--danger)', marginBottom: 12 }}>{status}</div>}
            <div style={{ display: 'flex', gap: 8, justifyContent: 'flex-end' }}>
              <button className="btn btn-outline btn-sm" onClick={cancelEdit}>Cancel</button>
              <button className="btn btn-primary btn-sm" onClick={handleSave} disabled={saving}>
                {saving ? 'Saving...' : 'Save'}
              </button>
            </div>
          </>
        ) : (
          <>
            <div className="hadith-label">Password</div>
            <div style={{ fontSize: '1.1rem', color: 'var(--text)', letterSpacing: 3 }}>••••••••</div>
            <button className="hadith-edit-btn" onClick={() => setEditing(true)} aria-label="Change password">
              ✏️
            </button>
          </>
        )}
      </div>
    </div>
  );
}
