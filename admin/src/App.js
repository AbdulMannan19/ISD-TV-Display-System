import { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { supabase } from './supabase';
import Topbar from './components/Topbar/Topbar';
import Sidebar from './components/Sidebar/Sidebar';
import Login from './pages/Login/Login';
import Slides from './pages/Slides/Slides';
import Hadiths from './pages/Hadiths/Hadiths';
import Profile from './pages/Profile/Profile';
import './App.css';

export default function App() {
  const [session, setSession] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setLoading(false);
    });
    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
    });
    return () => subscription.unsubscribe();
  }, []);

  if (loading) return <div className="loading">Loading...</div>;
  if (!session) return <Login />;

  return (
    <BrowserRouter>
      <div className="app">
        <Topbar />
        <Sidebar />
        <main className="main">
          <Routes>
            <Route path="/slides" element={<Slides />} />
            <Route path="/hadiths" element={<Hadiths />} />
            <Route path="/profile" element={<Profile />} />
            <Route path="*" element={<Navigate to="/slides" />} />
          </Routes>
        </main>
      </div>
    </BrowserRouter>
  );
}
