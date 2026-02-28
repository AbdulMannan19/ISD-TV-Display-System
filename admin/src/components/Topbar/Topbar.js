import React from 'react';
import { Link } from 'react-router-dom';
import './Topbar.css';

export default function Topbar() {
  return (
    <div className="topbar">
      <div className="topbar-title">🕌 Islamic Society of Denton</div>
      <Link to="/profile" className="topbar-profile" aria-label="Profile">👤</Link>
    </div>
  );
}
