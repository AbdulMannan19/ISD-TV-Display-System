import React, { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, Navigate, NavLink } from 'react-router-dom';
import { supabase } from './supabase';
import Login from './pages/Login';
import Slides from './pages/Slides';
import Hadiths from './pages/Hadiths';
import Profile from './pages/Profile';
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
          <NavLink to="/slides">Slides</NavLink>
          <NavLink to="/hadiths">Hadiths</NavLink>
          <NavLink to="/profile">Profile</NavLink>
          <button onClick={() => supabase.auth.signOut()}>Logout</button>
        </nav>
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
