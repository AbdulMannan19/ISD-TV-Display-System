import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../../supabase';
import '../Login/Login.css';
import './UpdatePassword.css';

const MosqueIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" className="mosque-svg">
    <path d="M12 3C12 3 8 6 8 10V20H16V10C16 6 12 3 12 3Z" />
    <path d="M4 20V14C4 12 5 11 6 10.5" />
    <path d="M20 20V14C20 12 19 11 18 10.5" />
    <path d="M2 20H22" />
    <circle cx="12" cy="10" r="1.5" />
  </svg>
);

const EyeIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" width="16" height="16">
    <path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0" />
    <circle cx="12" cy="12" r="3" />
  </svg>
);

const EyeOffIcon = () => (
  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" width="16" height="16">
    <path d="M10.733 5.076a10.744 10.744 0 0 1 11.205 6.575 1 1 0 0 1 0 .696 10.747 10.747 0 0 1-1.444 2.49" />
    <path d="M14.084 14.158a3 3 0 0 1-4.242-4.242" />
    <path d="M17.479 17.499a10.75 10.75 0 0 1-15.417-5.151 1 1 0 0 1 0-.696 10.75 10.75 0 0 1 4.446-5.143" />
    <path d="m2 2 20 20" />
  </svg>
);

export default function UpdatePassword({ onComplete }) {
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');

    if (password.length < 6) {
      setError('Password must be at least 6 characters');
      return;
    }

    if (password !== confirmPassword) {
      setError('Passwords do not match');
      return;
    }

    setLoading(true);
    const { error } = await supabase.auth.updateUser({ password });

    if (error) {
      console.error('[UpdatePassword] Error:', error);
      setError(error.message);
      setLoading(false);
    } else {
      console.log('[UpdatePassword] Password updated successfully');
      window.location.hash = '';
      if (onComplete) onComplete();
      navigate('/profile');
    }
  };

  return (
    <div className="login-page">
      <div className="login-left">
        <img src="/images/mosque-pattern.jpg" alt="Islamic pattern" className="login-bg-img" />
        <div className="login-overlay" />
        <div className="login-quote">
          <p>"Indeed, the first House [of worship] established for mankind was that at Makkah – blessed and a guidance for the worlds."</p>
          <span className="login-quote-source">— Quran 3:96</span>
        </div>
      </div>

      <div className="login-right">
        <div className="login-form-wrapper">
          <div className="login-brand">
            <div className="login-brand-icon"><MosqueIcon /></div>
            <h1 className="login-brand-name">Islamic Society of Denton</h1>
            <p className="login-brand-sub">Set your new password</p>
          </div>

          <form className="login-form" onSubmit={handleSubmit}>
            <div className="form-group">
              <label>New Password</label>
              <div className="input-with-icon">
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Enter your new password"
                  required
                />
                <button
                  type="button"
                  className="toggle-password"
                  onClick={() => setShowPassword(!showPassword)}
                  aria-label={showPassword ? 'Hide password' : 'Show password'}
                >
                  {showPassword ? <EyeOffIcon /> : <EyeIcon />}
                </button>
              </div>
            </div>

            <div className="form-group">
              <label>Confirm Password</label>
              <div className="input-with-icon">
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  placeholder="Confirm your new password"
                  required
                />
              </div>
            </div>

            {error && <div className="login-error">{error}</div>}

            <button type="submit" className="login-submit" disabled={loading}>
              {loading ? (
                <span className="login-spinner-wrap">
                  <span className="login-spinner" />
                  Updating...
                </span>
              ) : 'Update Password'}
            </button>
          </form>

          <p className="login-footer">Managed by Islamic Society of Denton</p>
        </div>
      </div>
    </div>
  );
}
