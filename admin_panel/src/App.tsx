import { useState, useEffect } from 'react';
import {
    Users,
    BookOpen,
    LayoutDashboard,
    Plus,
    Trash2,
    Search,
    School,
    Star,
    Music,
    X,
    Calendar,
    MessageSquare
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { collection, query, onSnapshot, addDoc, serverTimestamp, deleteDoc, doc } from 'firebase/firestore';
import { db } from './firebase';

const App = () => {
    const [activeTab, setActiveTab] = useState('dashboard');
    const [searchTerm, setSearchTerm] = useState('');
    const [stats, setStats] = useState({ users: 0, stories: 0, rhymes: 0, stars: 0 });
    const [users, setUsers] = useState<any[]>([]);
    const [stories, setStories] = useState<any[]>([]);
    const [rhymes, setRhymes] = useState<any[]>([]);
    const [questions, setQuestions] = useState<any[]>([]);
    const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);

    useEffect(() => {
        // Listen to Users
        const unsubUsers = onSnapshot(query(collection(db, 'users')), (snapshot) => {
            const userData = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            setUsers(userData);
            let totalStars = 0;
            userData.forEach((u: any) => { if (u.progress?.totalStars) totalStars += u.progress.totalStars; });
            setStats(prev => ({ ...prev, users: userData.length, stars: totalStars }));
        });

        // Listen to Stories
        const unsubStories = onSnapshot(query(collection(db, 'stories')), (snapshot) => {
            setStories(snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })));
            setStats(prev => ({ ...prev, stories: snapshot.docs.length }));
        });

        // Listen to Rhymes
        const unsubRhymes = onSnapshot(query(collection(db, 'rhymes')), (snapshot) => {
            setRhymes(snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })));
            setStats(prev => ({ ...prev, rhymes: snapshot.docs.length }));
        });

        // Listen to Forum
        const unsubForum = onSnapshot(query(collection(db, 'forum_questions')), (snapshot) => {
            setQuestions(snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() })));
        });

        return () => {
            unsubUsers(); unsubStories(); unsubRhymes(); unsubForum();
        };
    }, []);

    const handleCreateNew = async (data: any) => {
       const col = data.type === 'story' ? 'stories' : 'rhymes';
                   
       // Map content structure
       let content = { ...data };
       
       await addDoc(collection(db, col), { ...content, createdAt: serverTimestamp() });
       setIsCreateModalOpen(false);
    };

    const handleDelete = async (col: string, id: string) => {
        if (window.confirm('Are you sure you want to delete this content?')) {
            await deleteDoc(doc(db, col, id));
        }
    };

    return (
        <div className="flex h-screen w-screen bg-slate-950 text-slate-100 overflow-hidden font-sans">
            {/* Sidebar */}
            <nav className="w-64 bg-slate-900 border-r border-slate-800 p-6 flex flex-col gap-8">
                <div className="flex items-center gap-3 px-2">
                    <div className="w-10 h-10 bg-gradient-to-br from-pink-500 to-violet-600 rounded-xl flex items-center justify-center shadow-lg shadow-pink-500/20">
                        <span className="text-xl font-black">அ</span>
                    </div>
                    <div>
                        <h1 className="font-black text-lg tracking-tight leading-none">AKARAVALAM</h1>
                        <p className="text-[10px] text-slate-500 font-bold tracking-widest uppercase mt-1">Admin Engine</p>
                    </div>
                </div>

                <div className="flex flex-col gap-1 overflow-y-auto custom-scrollbar pr-2">
                    <NavItem icon={<LayoutDashboard size={20} />} label="Dashboard" active={activeTab === 'dashboard'} onClick={() => setActiveTab('dashboard')} />
                    <NavItem icon={<Users size={20} />} label="Learners" active={activeTab === 'users'} onClick={() => setActiveTab('users')} />
                    <NavItem icon={<BookOpen size={20} />} label="Stories" active={activeTab === 'stories'} onClick={() => setActiveTab('stories')} />
                    <NavItem icon={<Music size={20} />} label="Rhymes" active={activeTab === 'rhymes'} onClick={() => setActiveTab('rhymes')} />
                    <NavItem icon={<MessageSquare size={20} />} label="Forum" active={activeTab === 'forum'} onClick={() => setActiveTab('forum')} />
                    <NavItem icon={<School size={20} />} label="Classrooms" active={activeTab === 'classrooms'} onClick={() => setActiveTab('classrooms')} />
                </div>

                <div className="mt-auto bg-slate-800/50 rounded-2xl p-4 border border-slate-700/50">
                    <p className="text-xs text-slate-400 mb-2">Logged in as</p>
                    <div className="flex items-center gap-3">
                        <div className="w-8 h-8 rounded-full bg-slate-700 flex items-center justify-center text-sm">👨‍🏫</div>
                        <div>
                            <p className="text-sm font-bold">Admin Master</p>
                            <p className="text-[10px] text-pink-500 font-bold uppercase tracking-widest">SUPERUSER</p>
                        </div>
                    </div>
                </div>
            </nav>

            {/* Main Content */}
            <main className="flex-1 overflow-y-auto p-10 custom-scrollbar">
                <header className="flex justify-between items-center mb-10">
                    <div>
                        <h2 className="text-3xl font-black tracking-tight capitalize">{activeTab}</h2>
                        <p className="text-slate-400 mt-1">Manage Akaravalam ecosystem</p>
                    </div>
                    <div className="flex gap-4">
                        <div className="relative">
                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500" size={18} />
                            <input 
                                type="text" 
                                placeholder="Search..." 
                                className="bg-slate-900 border border-slate-800 rounded-xl py-2 pl-10 pr-4 w-48 text-sm focus:ring-2 focus:ring-pink-500/50 outline-none" 
                                value={searchTerm} 
                                onChange={(e) => setSearchTerm(e.target.value)} 
                            />
                        </div>
                        <button onClick={() => setIsCreateModalOpen(true)} className="bg-pink-600 hover:bg-pink-500 text-white font-bold py-2 px-6 rounded-xl flex items-center gap-2 shadow-lg shadow-pink-600/20 transition-all">
                            <Plus size={20} /><span>Create New</span>
                        </button>
                    </div>
                </header>

                <AnimatePresence mode="wait">
                    {activeTab === 'dashboard' && <DashboardView key="dashboard" stats={stats} users={users} />}
                    {activeTab === 'users' && <UsersView key="users" users={users} onDelete={(id: string) => handleDelete('users', id)} />}
                    {activeTab === 'stories' && <ListView key="stories" items={stories} collection="stories" onDelete={(id: string) => handleDelete('stories', id)} />}
                    {activeTab === 'rhymes' && <ListView key="rhymes" items={rhymes} collection="rhymes" onDelete={(id: string) => handleDelete('rhymes', id)} />}
                    {activeTab === 'forum' && <ForumView key="forum" items={questions} onDelete={(id: string) => handleDelete('forum_questions', id)} />}
                    {activeTab === 'classrooms' && <ClassroomsView key="classrooms" users={users} />}
                </AnimatePresence>
            </main>

            <AnimatePresence>
                {isCreateModalOpen && <CreateModal onClose={() => setIsCreateModalOpen(false)} onSave={handleCreateNew} />}
            </AnimatePresence>
        </div>
    );
};

const ClassroomsView = ({ users }: any) => {
    return (
        <div className="grid grid-cols-2 gap-8">
            <div className="bg-slate-900 p-8 rounded-3xl border border-slate-800">
                <div className="flex justify-between items-center mb-6">
                    <h3 className="text-xl font-bold">Main Classroom</h3>
                    <span className="bg-green-500/10 text-green-500 text-[10px] font-black px-2 py-1 rounded">ACTIVE</span>
                </div>
                <div className="space-y-4">
                    <div className="flex justify-between text-sm"><span className="text-slate-500">Total Students</span><span className="font-bold">{users.length}</span></div>
                    <div className="flex justify-between text-sm"><span className="text-slate-500">Average Progress</span><span className="font-bold text-pink-500">78%</span></div>
                </div>
                <button className="w-full mt-8 py-3 bg-slate-800 hover:bg-slate-700 rounded-xl font-bold text-xs transition-all">MANAGE STUDENTS</button>
            </div>
            <div className="bg-slate-900 p-8 rounded-3xl border border-dashed border-slate-800 flex flex-col items-center justify-center text-slate-600">
                <Plus size={32} className="mb-4 opacity-20" />
                <p className="text-xs font-black uppercase tracking-widest">Create New Section</p>
            </div>
        </div>
    );
};

const CreateModal = ({ onClose, onSave }: { onClose: () => void, onSave: (data: any) => void }) => {
    const [type, setType] = useState('story');
    const [title, setTitle] = useState('');
    const [englishTitle, setEnglishTitle] = useState('');
    const [extra, setExtra] = useState(''); // Moral or Date or Tamil Meaning
    const [sentence, setSentence] = useState(''); // For daily word

    return (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center z-50 p-6">
            <motion.div initial={{ scale: 0.9, opacity: 0 }} animate={{ scale: 1, opacity: 1 }} exit={{ scale: 0.9, opacity: 0 }} className="bg-slate-900 border border-slate-800 w-full max-w-md rounded-3xl p-8 max-h-[90vh] overflow-y-auto custom-scrollbar">
                <div className="flex justify-between items-center mb-6">
                    <h3 className="text-xl font-bold">Add New Content</h3>
                    <button onClick={onClose} className="text-slate-500 hover:text-white transition-colors"><X size={24} /></button>
                </div>
                <div className="space-y-6">
                    <div>
                        <label className="text-[10px] font-black uppercase text-slate-500 mb-2 block tracking-widest">Content Type</label>
                        <div className="grid grid-cols-2 gap-2">
                             {['story', 'rhyme'].map(t => (
                                 <button key={t} onClick={() => setType(t)} className={`py-2 rounded-xl border font-bold text-[10px] uppercase tracking-tighter transition-all ${type === t ? 'bg-pink-600 border-pink-500' : 'bg-slate-800 border-slate-700 text-slate-400 hover:border-slate-600'}`}>{t.replace('_', ' ')}</button>
                             ))}
                        </div>
                    </div>
                    <InputField label={type === 'story' ? "Tamil Title" : "Tamil Word"} value={title} onChange={setTitle} placeholder="e.g. மரம்" />
                    <InputField label={type === 'story' ? "English Title" : "English Meaning"} value={englishTitle} onChange={setEnglishTitle} placeholder="e.g. Tree" />
                    
                    {type === 'story' && <InputField label="Moral" value={extra} onChange={setExtra} placeholder="e.g. Help everyone" />}
                    
                    <button 
                        onClick={() => onSave({ 
                            type, 
                            title, 
                            englishTitle, 
                            extra,
                            ...(type === 'story' ? { moral: extra } : {}) 
                        })} 
                        className="w-full bg-pink-600 hover:bg-pink-500 text-white font-bold py-4 rounded-2xl shadow-lg shadow-pink-600/20 mt-4 transition-all"
                    >
                        Publish to App
                    </button>
                </div>
            </motion.div>
        </div>
    );
};

const InputField = ({ label, value, onChange, placeholder }: any) => (
    <div>
        <label className="text-[10px] font-black uppercase text-slate-500 mb-2 block tracking-widest">{label}</label>
        <input 
            value={value} 
            onChange={(e) => onChange(e.target.value)} 
            placeholder={placeholder} 
            className="bg-slate-800 border border-slate-700 rounded-xl w-full p-3 focus:ring-2 focus:ring-pink-500/50 outline-none transition-all placeholder:text-slate-600 text-sm" 
        />
    </div>
);

const ForumView = ({ items, onDelete }: any) => (
    <div className="grid grid-cols-1 gap-4">
        {items.length === 0 ? <EmptyState icon={<MessageSquare />} label="No forum topics yet" /> : items.map((item: any) => (
            <div key={item.id} className="bg-slate-900 border border-slate-800 p-6 rounded-2xl flex justify-between items-center group hover:border-pink-500/30 transition-all">
                <div>
                    <h4 className="font-bold text-lg">{item.title}</h4>
                    <p className="text-sm text-slate-400 max-w-2xl">{item.content?.substring(0, 100)}...</p>
                    <div className="flex gap-4 mt-3 text-[10px] font-black uppercase tracking-widest text-pink-500">
                        <span className="bg-pink-500/10 px-2 py-1 rounded">👤 {item.userName}</span>
                        <span className="bg-pink-500/10 px-2 py-1 rounded">💬 {item.answersCount} Answers</span>
                    </div>
                </div>
                <button onClick={() => onDelete(item.id)} className="p-3 text-slate-600 hover:text-red-500 transition-all"><Trash2 size={24} /></button>
            </div>
        ))}
    </div>
);

const ListView = ({ items, onDelete }: any) => (
   <div className="grid grid-cols-2 gap-6">
        {items.length === 0 ? <div className="col-span-2"><EmptyState icon={<BookOpen />} label="No content found" /></div> : items.map((item: any) => (
            <div key={item.id} className="bg-slate-900 p-6 rounded-2xl border border-slate-800 flex justify-between items-center group hover:border-pink-500/30 transition-all">
                <div className="flex items-center gap-4">
                    <div className="w-12 h-12 bg-slate-800 rounded-xl flex items-center justify-center text-2xl shadow-inner font-bold">
                        {item.icon || (item.title?.includes('Lion') ? '🦁' : '📖')}
                    </div>
                    <div>
                        <h4 className="font-bold text-slate-100">{item.title || item.word}</h4>
                        <p className="text-xs text-slate-500 font-medium tracking-tight">{item.englishTitle || item.english || item.date}</p>
                    </div>
                </div>
                <button onClick={() => onDelete(item.id)} className="p-2 opacity-0 group-hover:opacity-100 text-slate-600 hover:text-red-500 transition-all"><Trash2 size={20} /></button>
            </div>
        ))}
    </div>
);

const DashboardView = ({ stats, users }: any) => (
    <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="space-y-8">
        <div className="grid grid-cols-3 gap-6">
            <StatCard label="Total Learners" value={stats.users} icon={<Users className="text-blue-400" />} />
            <StatCard label="Live Stories" value={stats.stories} icon={<BookOpen className="text-green-400" />} />
            <StatCard label="Tamil Rhymes" value={stats.rhymes} icon={<Music className="text-pink-400" />} />
        </div>
        
        <div className="grid grid-cols-3 gap-8">
            <div className="col-span-2 bg-slate-900 rounded-3xl p-8 border border-slate-800 h-80 flex flex-col justify-center items-center relative overflow-hidden">
                <div className="absolute inset-0 bg-gradient-to-br from-pink-500/5 to-transparent"></div>
                <p className="text-lg font-black text-slate-300 relative z-10 tracking-widest uppercase">Ecosystem Analytics</p>
                <p className="text-sm text-slate-500 relative z-10 mt-2 font-mono">Live Data Stream Active</p>
            </div>
            <div className="bg-slate-900 rounded-3xl p-8 border border-slate-800 h-80 overflow-y-auto custom-scrollbar">
                <h3 className="text-xs font-black uppercase text-slate-500 tracking-widest mb-6">Recent Activity</h3>
                <div className="space-y-6">
                    {users.slice(0, 5).map((u: any) => (
                        <div key={u.id} className="flex items-center gap-4">
                            <div className="w-10 h-10 rounded-xl bg-slate-800 flex items-center justify-center text-sm shadow-inner group-hover:scale-110 transition-transform">👤</div>
                            <div>
                                <p className="text-xs font-black text-slate-100">{u.displayName}</p>
                                <p className="text-[10px] text-pink-500 font-bold uppercase tracking-tighter">Level {u.progress?.level || 1} • {u.progress?.totalStars || 0} Stars</p>
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    </motion.div>
);

const UsersView = ({ users, onDelete }: any) => (
    <div className="bg-slate-900 rounded-3xl border border-slate-800 overflow-hidden shadow-2xl">
        <table className="w-full text-left text-sm">
            <thead className="bg-slate-800/80 text-[10px] font-black uppercase tracking-widest text-slate-400 font-mono">
                <tr>
                    <th className="p-6">Learner Profile</th>
                    <th className="p-6">Expertise</th>
                    <th className="p-6">Growth</th>
                    <th className="p-6 text-right">Control</th>
                </tr>
            </thead>
            <tbody className="divide-y divide-slate-800">
                {users.map((user: any) => (
                    <tr key={user.id} className="hover:bg-slate-800/40 transition-colors group">
                        <td className="p-6">
                            <div className="flex items-center gap-4">
                                <div className="w-10 h-10 rounded-full bg-slate-800 flex items-center justify-center border border-slate-700 font-bold group-hover:border-pink-500/50 transition-all">👦</div>
                                <div><p className="font-black text-slate-200">{user.displayName}</p><p className="text-[11px] text-slate-500 font-mono">{user.email || 'guest_user'}</p></div>
                            </div>
                        </td>
                        <td className="p-6 font-mono font-black text-xs text-blue-400 bg-blue-500/5 rounded-lg">Level {user.progress?.level || 1}</td>
                        <td className="p-6">
                            <div className="flex items-center gap-2 font-black text-amber-500">
                                <Star size={14} fill="currentColor" />
                                <span>{user.progress?.totalStars || 0}</span>
                            </div>
                        </td>
                        <td className="p-6 text-right">
                            <button onClick={() => onDelete(user.id)} className="text-slate-600 hover:text-red-500 transition-all opacity-0 group-hover:opacity-100"><Trash2 size={20} /></button>
                        </td>
                    </tr>
                ))}
            </tbody>
        </table>
    </div>
);

const EmptyState = ({ icon, label }: any) => (
    <div className="bg-slate-900/50 border border-dashed border-slate-800 rounded-3xl p-20 flex flex-col items-center justify-center text-slate-600">
        <div className="mb-4 scale-150 opacity-20">{icon}</div>
        <p className="font-black uppercase tracking-widest text-xs">{label}</p>
    </div>
);

const NavItem = ({ icon, label, active, onClick }: any) => (
    <button onClick={onClick} className={`flex items-center gap-3 px-4 py-3 rounded-xl transition-all font-black text-xs uppercase tracking-widest ${active ? 'bg-pink-600 text-white shadow-lg shadow-pink-600/30 ring-1 ring-pink-500' : 'text-slate-500 hover:bg-slate-800 hover:text-slate-300'}`}>
        {icon}<span className="ml-1">{label}</span>
    </button>
);

const StatCard = ({ label, value, icon }: any) => (
    <div className="bg-slate-900 p-6 rounded-3xl border border-slate-800 hover:border-pink-500/30 transition-all group overflow-hidden relative">
        <div className="absolute -right-4 -bottom-4 bg-white/5 w-24 h-24 rounded-full blur-2xl group-hover:scale-150 transition-transform"></div>
        <div className="flex justify-between items-start mb-4"><div className="p-3 bg-slate-800 rounded-2xl shadow-inner group-hover:rotate-12 transition-transform">{icon}</div></div>
        <h4 className="text-4xl font-black mb-1 tracking-tighter">{value}</h4>
        <p className="text-slate-500 text-[10px] font-black uppercase tracking-widest">{label}</p>
    </div>
);

export default App;
