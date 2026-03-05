import { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { supabase } from './supabase';
import Topbar from './components/Topbar/Topbar';
import Sidebar from './components/Sidebar/Sidebar';
import Login from './pages/Login/Login';
import SetPassword from './pages/SetPassword/SetPassword';
import Slides from './pages/Slides/Slides';
import Profile from './pages/Profile/Profile';
import './App.css';

// Check hash ONCE at page load, before React even renders
const hash = window.location.hash;
const isInvite = hash.includes('type=invite') || hash.includes('type=recovery');

function AppContent() {
  const [session, setSession] = useState(null);
  const [loading, setLoading] = useState(true);
  const [collapsed, setCollapsed] = useState(false);
  const [needsPassword, setNeedsPassword] = useState(isInvite);

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setLoading(false);
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
      setLoading(false);
    });

    return () => subscription.unsubscribe();
  }, []);

  if (loading) return <div className="loading">Loading...</div>;

  if (needsPassword && session) {
    return <SetPassword onDone={() => { setNeedsPassword(false); window.location.hash = ''; }} />;
  }

  if (!session) {
    if (isInvite) {
      return <div className="loading">Processing invitation...</div>;
    }
    return <Login />;
  }

  const email = session.user?.email || '';

  return (
    <div className="app">
      <Sidebar collapsed={collapsed} onToggle={() => setCollapsed(!collapsed)} />
      <Topbar collapsed={collapsed} email={email} />
      <main className={`main${collapsed ? ' collapsed' : ''}`}>
        <Routes>
          <Route path="/slides" element={<Slides />} />
          <Route path="/profile" element={<Profile />} />
          <Route path="*" element={<Navigate to="/slides" />} />
        </Routes>
      </main>
    </div>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <AppContent />
    </BrowserRouter>
  );
}
