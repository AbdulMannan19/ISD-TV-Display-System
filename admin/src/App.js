import { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { supabase } from './supabase';
import Topbar from './components/Topbar/Topbar';
import Sidebar from './components/Sidebar/Sidebar';
import Login from './pages/Login/Login';
import UpdatePassword from './pages/UpdatePassword/UpdatePassword';
import Slides from './pages/Slides/Slides';
import PrayerTimes from './pages/PrayerTimes/PrayerTimes';
import Profile from './pages/Profile/Profile';
import Alerts from './pages/Alerts/Alerts';
import Hadiths from './pages/Content/Hadiths';
import Duas from './pages/Content/Duas';
import Verses from './pages/Content/Verses';
import Support from './pages/Support/Support';
import EmbedPrayerTimes from './pages/Embed/EmbedPrayerTimes';
import './App.css';

function AppContent() {
  const [session, setSession] = useState(null);
  const [loading, setLoading] = useState(true);
  const [collapsed, setCollapsed] = useState(false);
  const [isPasswordRecovery, setIsPasswordRecovery] = useState(false);

  useEffect(() => {
    const { data: { subscription } } = supabase.auth.onAuthStateChange((event, session) => {
      setSession(session);

      if (event === 'PASSWORD_RECOVERY') {
        setIsPasswordRecovery(true);
      }

      setLoading(false);
    });

    return () => subscription.unsubscribe();
  }, []);

  if (loading) return <div className="loading">Loading...</div>;

  if (isPasswordRecovery && session) {
    return <UpdatePassword onComplete={() => setIsPasswordRecovery(false)} />;
  }

  if (!session) return <Login />;

  const email = session.user?.email || '';

  return (
    <div className="app">
      <Sidebar collapsed={collapsed} onToggle={() => setCollapsed(!collapsed)} />
      <Topbar collapsed={collapsed} email={email} />
      <main className={`main${collapsed ? ' collapsed' : ''}`}>
        <Routes>
          <Route path="/slides" element={<Slides />} />
          <Route path="/prayer-times" element={<PrayerTimes />} />
          <Route path="/alerts" element={<Alerts />} />
          <Route path="/hadiths" element={<Hadiths />} />
          <Route path="/duas" element={<Duas />} />
          <Route path="/verses" element={<Verses />} />
          <Route path="/profile" element={<Profile />} />
          <Route path="/support" element={<Support />} />
          <Route path="*" element={<Navigate to="/prayer-times" />} />
        </Routes>
      </main>
    </div>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/embed/prayer-times" element={<EmbedPrayerTimes />} />
        <Route path="*" element={<AppContent />} />
      </Routes>
    </BrowserRouter>
  );
}
