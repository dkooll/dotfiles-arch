local opts = { noremap = true, silent = true }

-- Change window layout
vim.keymap.set('n', ',h', '<C-w>H', opts) -- ,h moves window left
vim.keymap.set('n', ',l', '<C-w>L', opts) -- ,l moves window right

-- Window movement with Ctrl+w followed by arrows
vim.keymap.set('n', '<C-w><Left>', '<C-w>h', opts)
vim.keymap.set('n', '<C-w><Down>', '<C-w>j', opts)
vim.keymap.set('n', '<C-w><Up>', '<C-w>k', opts)
vim.keymap.set('n', '<C-w><Right>', '<C-w>l', opts)

-- Move selected line / block of text in visual mode
vim.keymap.set("v", "<S-k>", ":m '<-2<CR>gv=gv", { silent = true })
vim.keymap.set("v", "<S-j>", ":m '>+1<CR>gv=gv", { silent = true })

-- scrolls up and down half a page centered
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)

-- Remap for dealing with visual line wraps
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })

-- better indenting
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- paste over currently selected text without yanking it
vim.keymap.set("v", "p", '"_dp', opts)
vim.keymap.set("v", "P", '"_dP', opts)

-- quick save and quit
vim.keymap.set('n', 'w', ':write!<CR>', opts)
vim.keymap.set('n', 'q', ':q!<CR>', opts)

-- Resize windows with Option/Alt + or -
vim.keymap.set("n", "≠", "<cmd>vertical resize +10<CR>", opts)
vim.keymap.set("n", "–", "<cmd>vertical resize -10<CR>", opts)

-- Buffer management keymaps
vim.keymap.set("n", "<Tab>", ":bnext<CR>", opts)
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>", opts)

-- Clear search highlight with Esc
vim.keymap.set("n", "<Esc>", "<cmd>noh<CR><Esc>", { desc = "Clear hlsearch", silent = true })
