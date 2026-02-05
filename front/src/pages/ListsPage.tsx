import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  useLists,
  useCreateList,
  useDeleteList,
  useUpdateList,
} from "../api/hooks";

interface ListsPageProps {
  onSelectList: (listId: string) => void;
}

export default function ListsPage({ onSelectList }: ListsPageProps) {
  const { data: lists = [], isLoading, error } = useLists();
  const createListMutation = useCreateList();
  const deleteListMutation = useDeleteList();
  const updateListMutation = useUpdateList();

  const [showCreateForm, setShowCreateForm] = useState(false);
  const [newListName, setNewListName] = useState("");
  const [newListDescription, setNewListDescription] = useState("");
  const [editingListId, setEditingListId] = useState<string | null>(null);
  const [editListName, setEditListName] = useState("");
  const [editListDescription, setEditListDescription] = useState("");

  async function handleCreateList(e: React.FormEvent) {
    e.preventDefault();
    if (!newListName.trim()) return;

    try {
      await createListMutation.mutateAsync({
        name: newListName.trim(),
        description: newListDescription.trim() || undefined,
      });
      setNewListName("");
      setNewListDescription("");
      setShowCreateForm(false);
    } catch (err) {
      console.error("Failed to create list:", err);
    }
  }

  async function handleDeleteList(id: string, e: React.MouseEvent) {
    e.stopPropagation();
    if (!confirm("Êtes-vous sûr de vouloir supprimer cette liste ?")) return;

    try {
      await deleteListMutation.mutateAsync(id);
    } catch (err) {
      console.error("Failed to delete list:", err);
    }
  }

  function startEditList(
    list: { id: string; name: string; description?: string },
    e: React.MouseEvent,
  ) {
    e.stopPropagation();
    setEditingListId(list.id);
    setEditListName(list.name);
    setEditListDescription(list.description || "");
  }

  function cancelEditList(e: React.MouseEvent) {
    e.stopPropagation();
    setEditingListId(null);
  }

  async function handleUpdateList(e: React.FormEvent, id: string) {
    e.preventDefault();
    e.stopPropagation();
    if (!editListName.trim()) return;

    try {
      await updateListMutation.mutateAsync({
        id,
        data: {
          name: editListName.trim(),
          description: editListDescription.trim() || undefined,
        },
      });
      setEditingListId(null);
    } catch (err) {
      console.error("Failed to update list:", err);
    }
  }

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <motion.div
          animate={{ rotate: 360 }}
          transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
          className="w-12 h-12 border-4 border-indigo-500 border-t-transparent rounded-full"
        />
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto px-4 py-8">
      {/* Header */}
      <motion.header
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-8"
      >
        <h1 className="text-3xl font-bold text-slate-800">
          📋 Mes Listes de Dépenses
        </h1>
        <motion.button
          whileHover={{ scale: 1.05 }}
          whileTap={{ scale: 0.95 }}
          onClick={() => setShowCreateForm(!showCreateForm)}
          className="px-6 py-3 bg-indigo-600 text-white rounded-xl font-medium shadow-lg shadow-indigo-200 hover:bg-indigo-700 transition-colors"
        >
          {showCreateForm ? "Annuler" : "+ Nouvelle Liste"}
        </motion.button>
      </motion.header>

      {/* Error Message */}
      <AnimatePresence>
        {error && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            exit={{ opacity: 0, height: 0 }}
            className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-xl mb-6"
          >
            {error instanceof Error ? error.message : "Une erreur est survenue"}
          </motion.div>
        )}
      </AnimatePresence>

      {/* Create Form */}
      <AnimatePresence>
        {showCreateForm && (
          <motion.form
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            exit={{ opacity: 0, height: 0 }}
            onSubmit={handleCreateList}
            className="bg-white rounded-2xl p-6 shadow-xl shadow-slate-200 mb-8 overflow-hidden"
          >
            <h3 className="text-xl font-semibold text-slate-800 mb-4">
              Créer une nouvelle liste
            </h3>
            <div className="space-y-4">
              <div>
                <label
                  htmlFor="listName"
                  className="block text-sm font-medium text-slate-700 mb-1"
                >
                  Nom de la liste *
                </label>
                <input
                  id="listName"
                  type="text"
                  value={newListName}
                  onChange={(e) => setNewListName(e.target.value)}
                  placeholder="Ex: Vacances été 2026"
                  required
                  disabled={createListMutation.isPending}
                  className="w-full px-4 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-transparent outline-none transition-all text-slate-800 bg-white placeholder:text-slate-400"
                />
              </div>
              <div>
                <label
                  htmlFor="listDescription"
                  className="block text-sm font-medium text-slate-700 mb-1"
                >
                  Description
                </label>
                <textarea
                  id="listDescription"
                  value={newListDescription}
                  onChange={(e) => setNewListDescription(e.target.value)}
                  placeholder="Description optionnelle..."
                  disabled={createListMutation.isPending}
                  className="w-full px-4 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-transparent outline-none transition-all resize-none h-24 text-slate-800 bg-white placeholder:text-slate-400"
                />
              </div>
              <motion.button
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                type="submit"
                disabled={createListMutation.isPending}
                className="w-full sm:w-auto px-6 py-3 bg-indigo-600 text-white rounded-xl font-medium shadow-lg shadow-indigo-200 hover:bg-indigo-700 disabled:bg-indigo-300 transition-colors"
              >
                {createListMutation.isPending
                  ? "Création..."
                  : "Créer la liste"}
              </motion.button>
            </div>
          </motion.form>
        )}
      </AnimatePresence>

      {/* Empty State */}
      {lists.length === 0 ? (
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          className="text-center py-16 bg-white rounded-2xl shadow-xl shadow-slate-200"
        >
          <motion.span
            className="text-6xl block mb-4"
            animate={{ y: [0, -10, 0] }}
            transition={{ duration: 2, repeat: Infinity }}
          >
            📝
          </motion.span>
          <h2 className="text-2xl font-semibold text-slate-800 mb-2">
            Aucune liste pour le moment
          </h2>
          <p className="text-slate-500">
            Créez votre première liste de dépenses partagées !
          </p>
        </motion.div>
      ) : (
        /* Lists Grid */
        <motion.div
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
          initial="hidden"
          animate="visible"
          variants={{
            visible: {
              transition: {
                staggerChildren: 0.1,
              },
            },
          }}
        >
          {lists.map((list) => (
            <motion.div
              key={list.id}
              variants={{
                hidden: { opacity: 0, y: 20 },
                visible: { opacity: 1, y: 0 },
              }}
              whileHover={{
                y: -4,
                boxShadow: "0 20px 40px -12px rgba(0, 0, 0, 0.15)",
              }}
              onClick={() => {
                if (editingListId === list.id) return;
                onSelectList(list.id);
              }}
              className="bg-white rounded-2xl p-6 shadow-lg shadow-slate-200 cursor-pointer transition-all"
            >
              <div className="flex justify-between items-start mb-3">
                <h3 className="text-xl font-semibold text-slate-800 truncate pr-2">
                  {list.name}
                </h3>
                <div className="flex items-center gap-2">
                  <motion.button
                    whileHover={{ scale: 1.1 }}
                    whileTap={{ scale: 0.9 }}
                    onClick={(e) => startEditList(list, e)}
                    className="text-slate-400 hover:text-indigo-600 transition-colors p-1"
                    title="Modifier"
                  >
                    ✏️
                  </motion.button>
                  <motion.button
                    whileHover={{ scale: 1.1 }}
                    whileTap={{ scale: 0.9 }}
                    onClick={(e) => handleDeleteList(list.id, e)}
                    className="text-slate-400 hover:text-red-500 transition-colors p-1"
                    title="Supprimer"
                  >
                    🗑️
                  </motion.button>
                </div>
              </div>
              {editingListId === list.id ? (
                <form
                  onSubmit={(e) => handleUpdateList(e, list.id)}
                  className="space-y-3"
                >
                  <input
                    value={editListName}
                    onChange={(e) => setEditListName(e.target.value)}
                    className="w-full px-3 py-2 bg-white border border-slate-200 rounded-lg outline-none text-slate-800"
                  />
                  <textarea
                    value={editListDescription}
                    onChange={(e) => setEditListDescription(e.target.value)}
                    className="w-full px-3 py-2 bg-white border border-slate-200 rounded-lg outline-none text-slate-800 resize-none h-20"
                    placeholder="Description"
                  />
                  <div className="flex justify-end gap-2">
                    <button
                      type="button"
                      onClick={cancelEditList}
                      className="px-3 py-2 bg-slate-100 text-slate-700 rounded-lg"
                    >
                      Annuler
                    </button>
                    <button
                      type="submit"
                      disabled={updateListMutation.isPending}
                      className="px-3 py-2 bg-indigo-600 text-white rounded-lg hover:bg-indigo-700 disabled:bg-indigo-300"
                    >
                      Enregistrer
                    </button>
                  </div>
                </form>
              ) : (
                <>
                  {list.description && (
                    <p className="text-slate-500 text-sm mb-4 line-clamp-2">
                      {list.description}
                    </p>
                  )}
                  <div className="text-xs text-slate-400">
                    Créée le{" "}
                    {new Date(list.createdAt).toLocaleDateString("fr-FR")}
                  </div>
                </>
              )}
            </motion.div>
          ))}
        </motion.div>
      )}
    </div>
  );
}
