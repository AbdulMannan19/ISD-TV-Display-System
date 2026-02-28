import React from 'react';
import { NavLink } from 'react-router-dom';
import { supabase } from '../../supabase';
import './Sidebar.css';

export default function Sidebar() {
  return (
    <aside className="sidebar">
      <NavLink to="/slides">🖼️ Slides</NavLink>
      <NavLink to="/hadiths">📖 Hadiths</NavLink>
      <div className="sidebar-bottom">
        <button onClick={() => supabase.auth.signOut()}>Sign Out</button>
      </div>
    </aside>
  );
}
