import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  useList,
  useCreateParticipant,
  useDeleteParticipant,
  useDeleteExpense,
  useBalances,
} from "../api/hooks";
import { getImageUrl } from "../api/client";
import ExpenseForm from "../components/ExpenseForm";
import BalanceView from "../components/BalanceView";

interface ListDetailPageProps {
  listId: string;
  onBack: () => void;
}

export default function ListDetailPage({
  listId,
  onBack,
}: ListDetailPageProps) {
  const { data: list, isLoading, error } = useList(listId);
  const { data: balances } = useBalances(listId);
  const createParticipantMutation = useCreateParticipant();
  const deleteParticipantMutation = useDeleteParticipant(listId);
  const deleteExpenseMutation = useDeleteExpense(listId);

  const [showExpenseForm, setShowExpenseForm] = useState(false);
  const [showAddParticipant, setShowAddParticipant] = useState(false);
  const [newParticipantName, setNewParticipantName] = useState("");
  const [activeTab, setActiveTab] = useState<"expenses" | "balance">(
    "expenses",
  );

  async function handleAddParticipant(e: React.FormEvent) {
    e.preventDefault();
    if (!newParticipantName.trim()) return;

    try {
      await createParticipantMutation.mutateAsync({
        listId,
        name: newParticipantName.trim(),
      });
      setNewParticipantName("");
      setShowAddParticipant(false);
    } catch (err) {
      console.error("Failed to add participant:", err);
    }
  }

  async function handleDeleteParticipant(id: string) {
    if (!confirm("Êtes-vous sûr de vouloir supprimer ce participant ?")) return;

    try {
      await deleteParticipantMutation.mutateAsync(id);
    } catch (err) {
      console.error("Failed to delete participant:", err);
    }
  }

  async function handleDeleteExpense(id: string) {
    if (!confirm("Êtes-vous sûr de vouloir supprimer cette dépense ?")) return;

    try {
      await deleteExpenseMutation.mutateAsync(id);
    } catch (err) {
      console.error("Failed to delete expense:", err);
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

  if (error || !list) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen gap-4">
        <p className="text-red-500">Liste non trouvée</p>
        <button
          onClick={onBack}
          className="px-6 py-3 bg-indigo-600 text-white rounded-xl font-medium"
        >
          Retour
        </button>
      </div>
    );
  }

  return (
    <div className="max-w-4xl mx-auto px-4 py-8">
      {/* Header */}
      <motion.header
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-8"
      >
        <button
          onClick={onBack}
          className="text-indigo-600 hover:text-indigo-800 font-medium mb-4 flex items-center gap-2 transition-colors"
        >
          ← Retour aux listes
        </button>
        <h1 className="text-3xl font-bold text-slate-800">{list.name}</h1>
        {list.description && (
          <p className="text-slate-500 mt-2">{list.description}</p>
        )}
      </motion.header>

      {/* Participants Section */}
      <motion.section
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
        className="bg-white rounded-2xl p-6 shadow-lg shadow-slate-200 mb-6"
      >
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-semibold text-slate-800">
            👥 Participants ({list.participants.length})
          </h2>
          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            onClick={() => setShowAddParticipant(!showAddParticipant)}
            className="px-4 py-2 bg-slate-100 text-slate-700 rounded-xl font-medium hover:bg-slate-200 transition-colors"
          >
            {showAddParticipant ? "Annuler" : "+ Ajouter"}
          </motion.button>
        </div>

        <AnimatePresence>
          {showAddParticipant && (
            <motion.form
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: "auto" }}
              exit={{ opacity: 0, height: 0 }}
              onSubmit={handleAddParticipant}
              className="flex gap-3 mb-4 overflow-hidden"
            >
              <input
                type="text"
                value={newParticipantName}
                onChange={(e) => setNewParticipantName(e.target.value)}
                placeholder="Nom du participant"
                required
                className="flex-1 px-4 py-2 border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-transparent outline-none text-slate-800 bg-white placeholder:text-slate-400"
              />
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                type="submit"
                disabled={createParticipantMutation.isPending}
                className="px-4 py-2 bg-indigo-600 text-white rounded-xl font-medium hover:bg-indigo-700 disabled:bg-indigo-300 transition-colors"
              >
                Ajouter
              </motion.button>
            </motion.form>
          )}
        </AnimatePresence>

        <div className="flex flex-wrap gap-2">
          {list.participants.length === 0 ? (
            <p className="text-slate-400 italic">
              Aucun participant. Ajoutez-en un pour commencer !
            </p>
          ) : (
            <AnimatePresence>
              {list.participants.map((participant) => (
                <motion.div
                  key={participant.id}
                  initial={{ opacity: 0, scale: 0.8 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.8 }}
                  className="flex items-center gap-2 bg-linear-to-r from-indigo-50 to-purple-50 px-4 py-2 rounded-full"
                >
                  <span className="text-slate-700">{participant.name}</span>
                  <button
                    onClick={() => handleDeleteParticipant(participant.id)}
                    className="text-slate-400 hover:text-red-500 transition-colors"
                  >
                    ×
                  </button>
                </motion.div>
              ))}
            </AnimatePresence>
          )}
        </div>
      </motion.section>

      {/* Tabs */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
        className="flex bg-white rounded-2xl shadow-lg shadow-slate-200 overflow-hidden mb-6"
      >
        {[
          { id: "expenses" as const, label: "💰 Dépenses" },
          { id: "balance" as const, label: "⚖️ Équilibre" },
        ].map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className={`flex-1 py-4 font-medium transition-all ${
              activeTab === tab.id
                ? "bg-indigo-600 text-white"
                : "text-slate-600 hover:bg-slate-50"
            }`}
          >
            {tab.label}
          </button>
        ))}
      </motion.div>

      {/* Tab Content */}
      <AnimatePresence mode="wait">
        {activeTab === "expenses" ? (
          <motion.section
            key="expenses"
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: 20 }}
            className="bg-white rounded-2xl p-6 shadow-lg shadow-slate-200"
          >
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-xl font-semibold text-slate-800">
                💰 Dépenses ({list.expenses.length})
              </h2>
              {list.participants.length > 0 && (
                <motion.button
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  onClick={() => setShowExpenseForm(!showExpenseForm)}
                  className="px-4 py-2 bg-indigo-600 text-white rounded-xl font-medium hover:bg-indigo-700 transition-colors"
                >
                  {showExpenseForm ? "Annuler" : "+ Ajouter"}
                </motion.button>
              )}
            </div>

            {list.participants.length === 0 && (
              <p className="text-slate-400 italic">
                Ajoutez d'abord des participants pour créer des dépenses.
              </p>
            )}

            <AnimatePresence>
              {showExpenseForm && list.participants.length > 0 && (
                <ExpenseForm
                  listId={listId}
                  participants={list.participants}
                  onSuccess={() => setShowExpenseForm(false)}
                  onCancel={() => setShowExpenseForm(false)}
                />
              )}
            </AnimatePresence>

            <div className="space-y-4">
              {list.expenses.length === 0 ? (
                <p className="text-slate-400 italic">
                  Aucune dépense pour le moment.
                </p>
              ) : (
                <AnimatePresence>
                  {list.expenses.map((expense, index) => (
                    <motion.div
                      key={expense.id}
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, x: -100 }}
                      transition={{ delay: index * 0.05 }}
                      className="relative bg-linear-to-r from-slate-50 to-white rounded-xl p-4 border border-slate-100"
                    >
                      <div className="flex justify-between items-start">
                        <div className="flex-1">
                          <h3 className="font-semibold text-slate-800 text-lg">
                            {expense.title}
                          </h3>
                          <p className="text-slate-500 text-sm">
                            Payé par{" "}
                            <span className="font-medium text-indigo-600">
                              {expense.payerName}
                            </span>
                          </p>
                          <p className="text-slate-400 text-sm">
                            Pour:{" "}
                            {expense.participants.map((p) => p.name).join(", ")}
                          </p>
                          <p className="text-slate-400 text-xs mt-1">
                            {new Date(expense.createdAt).toLocaleDateString(
                              "fr-FR",
                            )}
                          </p>
                        </div>
                        <div className="text-right">
                          <span className="text-2xl font-bold text-emerald-600">
                            {expense.amount.toFixed(2)} €
                          </span>
                        </div>
                      </div>
                      {expense.imageUrl && (
                        <a
                          href={getImageUrl(expense.imageUrl)}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="mt-3 block"
                        >
                          <img
                            src={getImageUrl(expense.imageUrl)}
                            alt="Reçu"
                            className="max-w-48 max-h-32 rounded-lg object-cover hover:opacity-90 transition-opacity"
                          />
                        </a>
                      )}
                      <motion.button
                        whileHover={{ scale: 1.1 }}
                        whileTap={{ scale: 0.9 }}
                        onClick={() => handleDeleteExpense(expense.id)}
                        className="absolute top-2 right-2 text-slate-400 hover:text-red-500 transition-colors"
                      >
                        🗑️
                      </motion.button>
                    </motion.div>
                  ))}
                </AnimatePresence>
              )}
            </div>
          </motion.section>
        ) : (
          <motion.div
            key="balance"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
          >
            {balances && <BalanceView balances={balances} />}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
