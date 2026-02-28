import React, { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate, NavLink } from 'react-router-dom';
import { supabase } from './supabase';
import Login from './pages/Login';
import PrayerTimes from './pages/PrayerTimes';
import Slides from './pages/Slides';
import DailyInfo from './pages/DailyInfo';
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
        <nav className="nav">
          <span className="nav-title">Masjid Admin</span>
          <NavLink to="/prayer-times">Prayer Times</NavLink>
          <NavLink to="/daily-info">Daily Info</NavLink>
          <NavLink to="/slides">Slides</NavLink>
          <button onClick={() => supabase.auth.signOut()}>Logout</button>
        </nav>
        <main className="main">
          <Routes>
            <Route path="/prayer-times" element={<PrayerTimes />} />
            <Route path="/daily-info" element={<DailyInfo />} />
            <Route path="/slides" element={<Slides />} />
            <Route path="*" element={<Navigate to="/prayer-times" />} />
          </Routes>
        </main>
      </div>
    </BrowserRouter>
  );
}
