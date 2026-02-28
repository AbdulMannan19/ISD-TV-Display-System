import React, { useState } from 'react';
import { supabase } from '../supabase';

export default function Profile() {
  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');
  const [saving, setSaving] = useState(false);
  const [status, setStatus] = useState('');

  const handleChangePassword = async (e) => {
    e.preventDefault();
    setStatus('');
    if (password.length < 6) {
      setStatus('Password must be at least 6 characters');
      return;
    }
    if (password !== confirm) {
      setStatus('Passwords do not match');
      return;
    }
    setSaving(true);
    const { error } = await supabase.auth.updateUser({ password });
    setSaving(false);
    if (error) {
      setStatus(error.message);
    } else {
      setStatus('Password updated');
      setPassword('');
      setConfirm('');
    }
  };

  return (
    <div>
      <h2>Profile</h2>
      <form onSubmit={handleChangePassword} style={{ marginTop: 16 }}>
        <div className="form-grid">
          <div className="form-group">
            <label>New Password</label>
            <input type="password" value={password} onChange={e => setPassword(e.target.value)} required />
          </div>
          <div className="form-group">
            <label>Confirm Password</label>
            <input type="password" value={confirm} onChange={e => setConfirm(e.target.value)} required />
          </div>
        </div>
        <button className="save-btn" type="submit" disabled={saving}>
          {saving ? 'Updating...' : 'Change Password'}
        </button>
        {status && <div className="status">{status}</div>}
      </form>
    </div>
  );
}
