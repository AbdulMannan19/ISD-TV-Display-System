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
import './App.css';

function AppContent() {
  const [session, setSession] = useState(null);
  const [loading, setLoading] = useState(true);
  const [collapsed, setCollapsed] = useState(false);
  const [isPasswordRecovery, setIsPasswordRecovery] = useState(() => {
    // Check immediately on mount, before any async operations
    const hash = window.location.hash;
    return hash.includes('type=recovery') || hash.includes('type=invite');
  });

  useEffect(() => {
    // Check hash for password recovery
    const hash = window.location.hash;
    console.log('[App] Current hash:', hash);
    
    if (hash.includes('type=recovery') || hash.includes('type=invite')) {
      console.log('[App] Password recovery detected in hash');
      setIsPasswordRecovery(true);
    }

    supabase.auth.getSession().then(({ data: { session } }) => {
      console.log('[App] Initial session:', session ? 'exists' : 'null');
      setSession(session);
      setLoading(false);
    });
    
    const { data: { subscription } } = supabase.auth.onAuthStateChange((event, session) => {
      console.log('[App] Auth state change:', event, 'Session:', session ? 'exists' : 'null');
      setSession(session);
      
      if (event === 'PASSWORD_RECOVERY' || event === 'SIGNED_IN') {
        const currentHash = window.location.hash;
        if (currentHash.includes('type=recovery') || currentHash.includes('type=invite')) {
          console.log('[App] PASSWORD_RECOVERY event fired or recovery hash detected');
          setIsPasswordRecovery(true);
        }
      }
    });
    
    return () => subscription.unsubscribe();
  }, []);

  if (loading) return <div className="loading">Loading...</div>;
  
  console.log('[App] Render state - isPasswordRecovery:', isPasswordRecovery, 'session:', session ? 'exists' : 'null');
  
  // Show password update page if user came from recovery email
  if (isPasswordRecovery && session) {
    console.log('[App] Rendering UpdatePassword page');
    return <UpdatePassword onComplete={() => setIsPasswordRecovery(false)} />;
  }
  
  if (!session) {
    console.log('[App] No session, rendering Login page');
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
          <Route path="/prayer-times" element={<PrayerTimes />} />
          <Route path="/profile" element={<Profile />} />
          <Route path="*" element={<Navigate to="/prayer-times" />} />
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
