import { motion } from "framer-motion";
import type { BalanceSummary } from "../types";

interface BalanceViewProps {
  balances: BalanceSummary;
}

export default function BalanceView({ balances }: BalanceViewProps) {
  return (
    <div className="space-y-6">
      {/* Summary Cards */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="grid grid-cols-2 md:grid-cols-4 gap-4"
      >
        {[
          {
            label: "Total des dépenses",
            value: `${balances.totalAmount.toFixed(2)} €`,
            color: "from-indigo-500 to-purple-600",
          },
          {
            label: "Participants",
            value: balances.participantCount.toString(),
            color: "from-emerald-500 to-teal-600",
          },
          {
            label: "Dépenses",
            value: balances.expenseCount.toString(),
            color: "from-amber-500 to-orange-600",
          },
          {
            label: "Moyenne/personne",
            value:
              balances.participantCount > 0
                ? `${(balances.totalAmount / balances.participantCount).toFixed(2)} €`
                : "0 €",
            color: "from-pink-500 to-rose-600",
          },
        ].map((card, index) => (
          <motion.div
            key={card.label}
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: index * 0.1 }}
            className={`bg-linear-to-br ${card.color} rounded-2xl p-4 text-white shadow-lg`}
          >
            <p className="text-sm opacity-90">{card.label}</p>
            <p className="text-2xl font-bold mt-1">{card.value}</p>
          </motion.div>
        ))}
      </motion.div>

      {/* Balances */}
      <motion.section
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
        className="bg-white rounded-2xl p-6 shadow-lg shadow-slate-200"
      >
        <h3 className="text-xl font-semibold text-slate-800 mb-4">
          📊 Solde de chacun
        </h3>
        {balances.balances.length === 0 ? (
          <p className="text-slate-400 italic">Aucun participant</p>
        ) : (
          <div className="space-y-3">
            {balances.balances.map((balance, index) => (
              <motion.div
                key={balance.participantId}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: index * 0.05 }}
                className="flex items-center justify-between p-4 bg-slate-50 rounded-xl"
              >
                <div>
                  <p className="font-semibold text-slate-800">
                    {balance.participantName}
                  </p>
                  <p className="text-sm text-slate-500">
                    A payé: {balance.totalPaid.toFixed(2)} € | Doit:{" "}
                    {balance.totalOwed.toFixed(2)} €
                  </p>
                </div>
                <div
                  className={`text-xl font-bold ${
                    balance.balance > 0
                      ? "text-emerald-600"
                      : balance.balance < 0
                        ? "text-red-500"
                        : "text-slate-500"
                  }`}
                >
                  {balance.balance > 0 ? "+" : ""}
                  {balance.balance.toFixed(2)} €
                </div>
              </motion.div>
            ))}
          </div>
        )}
      </motion.section>

      {/* Transactions */}
      <motion.section
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3 }}
        className="bg-white rounded-2xl p-6 shadow-lg shadow-slate-200"
      >
        <h3 className="text-xl font-semibold text-slate-800 mb-4">
          💸 Remboursements à effectuer
        </h3>
        {balances.transactions.length === 0 ? (
          <motion.div
            initial={{ scale: 0.9 }}
            animate={{ scale: 1 }}
            className="text-center py-8 bg-emerald-50 rounded-xl"
          >
            <motion.span
              className="text-4xl block mb-2"
              animate={{ rotate: [0, 10, -10, 0] }}
              transition={{ duration: 0.5, repeat: Infinity, repeatDelay: 2 }}
            >
              ✅
            </motion.span>
            <p className="text-emerald-600 font-medium">
              Tout le monde est à jour !
            </p>
          </motion.div>
        ) : (
          <div className="space-y-3">
            {balances.transactions.map((transaction, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: index * 0.1 }}
                className="flex items-center justify-between p-4 bg-amber-50 border-l-4 border-amber-400 rounded-xl"
              >
                <div className="flex items-center gap-3">
                  <span className="font-semibold text-red-600">
                    {transaction.fromName}
                  </span>
                  <motion.span
                    className="text-slate-400"
                    animate={{ x: [0, 5, 0] }}
                    transition={{ duration: 1, repeat: Infinity }}
                  >
                    →
                  </motion.span>
                  <span className="font-semibold text-emerald-600">
                    {transaction.toName}
                  </span>
                </div>
                <span className="text-xl font-bold text-slate-800">
                  {transaction.amount.toFixed(2)} €
                </span>
              </motion.div>
            ))}
          </div>
        )}
      </motion.section>
    </div>
  );
}
