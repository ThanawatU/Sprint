<template>
    <div class="">
        <AdminHeader />
        <AdminSidebar />

        <!-- Main Content -->
        <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">
            <!-- Page Title -->
            <div class="mx-auto max-w-8xl">
                <!-- Title -->
                <div class="flex flex-col gap-3 mb-6 sm:flex-row sm:items-center sm:justify-between">
                    <div class="flex items-center gap-3">
                        <h1 class="text-2xl font-semibold text-gray-800">Incident Management</h1>
                    </div>

                    <!-- Quick Search -->
                    <div class="flex items-center gap-2">
                        <input v-model.trim="filters.q" @keyup.enter="applyFilters" type="text"
                            placeholder="ค้นหา รายละเอียด / ผู้แจ้ง"
                            class="max-w-full px-3 py-2 border border-gray-300 rounded-md w-72 focus:outline-none focus:ring-2 focus:ring-blue-500" />
                        <button @click="applyFilters"
                            class="px-4 py-2 text-white bg-blue-600 rounded-md cursor-pointer hover:bg-blue-700">
                            ค้นหา
                        </button>
                    </div>
                </div>

                <!-- Stats Cards -->
                <div class="grid grid-cols-1 gap-4 mb-6 sm:grid-cols-2 lg:grid-cols-2">

                    <!-- Total Incidents -->
                    <div class="bg-white border border-gray-200 rounded-lg shadow-sm p-6">
                        <p class="text-sm text-gray-500">Total Incidents</p>
                        <p class="text-3xl font-bold text-gray-900 mt-2">
                            {{ stats.total }}
                        </p>
                    </div>

                    <!-- Resolved Today -->
                    <div class="bg-white border border-gray-200 rounded-lg shadow-sm p-6">
                        <p class="text-sm text-gray-500">Resolved Today</p>
                        <p class="text-3xl font-bold text-green-600 mt-2">
                            {{ stats.resolvedToday }}
                        </p>
                    </div>

                </div>

                <!-- Status Distribution -->
                <div class="bg-white border border-gray-300 rounded-lg shadow-sm mb-6 p-6">
                    <h3 class="text-lg font-semibold text-gray-800 mb-4">สถานะ Incident</h3>
                    <div class="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4">
                        <div v-for="status in statusList"
                            :key="status.value"
                            class="p-4 border border-gray-200 rounded-lg hover:shadow-md transition-shadow cursor-pointer"
                            @click="filterByStatus(status.value)">
                            <p class="text-xs font-medium text-gray-600 mb-1">{{ status.label }}</p>
                            <p class="text-2xl font-bold" :class="status.color">
                                {{ stats.byStatus[status.value] || 0 }}
                            </p>
                        </div>
                    </div>
                </div>

                <!-- Filters -->
                <div class="mb-4 bg-white border border-gray-300 rounded-lg shadow-sm">
                    <div class="grid grid-cols-1 gap-3 px-4 py-4 sm:px-6 lg:grid-cols-4">
                        <!-- Status Filter -->
                        <div>
                            <label class="block mb-1 text-xs font-medium text-gray-600">สถานะ</label>
                            <select v-model="filters.status"
                                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500">
                                <option value="">ทั้งหมด</option>
                                <option value="PENDING">PENDING</option>
                                <option value="UNDER_INVESTIGATION">UNDER_INVESTIGATION</option>
                                <option value="RESOLVED">RESOLVED</option>
                                <option value="REJECTED">REJECTED</option>
                            </select>
                        </div>

                        <!-- Category Filter -->
                        <div>
                            <label class="block mb-1 text-xs font-medium text-gray-600">ประเภท</label>
                            <select v-model="filters.category"
                                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500">
                                <option value="">ทั้งหมด</option>
                                <option value="DANGEROUS_DRIVING">Dangerous Driving</option>
                                <option value="AGGRESSIVE_BEHAVIOR">Aggressive Behavior</option>
                                <option value="HARASSMENT">Harassment</option>
                                <option value="NO_SHOW">No Show</option>
                                <option value="FRAUD_OR_SCAM">Fraud / Scam</option>
                                <option value="OTHER">Other</option>
                            </select>
                        </div>

                        <!-- Sort -->
                        <div>
                            <label class="block mb-1 text-xs font-medium text-gray-600">เรียงตาม</label>
                            <select v-model="filters.sort"
                                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500">
                                <option value="">ค่าเริ่มต้น (ล่าสุด)</option>
                                <option value="createdAt:desc">แจ้งเหตุล่าสุด → เก่าสุด</option>
                                <option value="createdAt:asc">แจ้งเหตุเก่าสุด → ล่าสุด</option>
                            </select>
                        </div>

                        <!-- Actions -->
                        <div class="flex items-end justify-end gap-2">
                            <button @click="clearFilters"
                                class="px-3 py-2 text-gray-700 border border-gray-300 rounded-md cursor-pointer hover:bg-gray-50">
                                ล้างตัวกรอง
                            </button>
                            <button @click="applyFilters"
                                class="px-4 py-2 text-white bg-blue-600 rounded-md cursor-pointer hover:bg-blue-700">
                                ใช้ตัวกรอง
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Incidents Table Card -->
                <div class="bg-white border border-gray-300 rounded-lg shadow-sm">
                    <div class="flex items-center justify-between px-4 py-4 border-b border-gray-200 sm:px-6">
                        <div class="text-sm text-gray-600">
                            ทั้งหมด {{ filteredIncidents.length }} รายการ
                        </div>
                    </div>

                    <!-- Loading / Error -->
                    <div v-if="isLoading" class="p-8 text-center text-gray-500">กำลังโหลดข้อมูล...</div>
                    <div v-else-if="loadError" class="p-8 text-center text-red-600">{{ loadError }}</div>

                    <!-- Table -->
                    <div v-else class="overflow-x-auto">
                        <table class="min-w-full divide-y divide-gray-200">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">Incident ID</th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">ผู้แจ้ง</th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">ประเภท</th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">Trip ID</th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">สถานะ</th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">วันที่แจ้ง</th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">Action</th>
                                </tr>
                            </thead>
                            <tbody class="bg-white divide-y divide-gray-200">
                                <tr v-for="incident in filteredIncidents" :key="incident.id" class="hover:bg-gray-50">
                                    <!-- Incident ID -->
                                    <td class="px-4 py-3 text-sm">
                                        <span class="font-mono text-xs text-gray-600">{{ incident.id?.slice(0, 8) }}...</span>
                                    </td>

                                    <!-- Reporter -->
                                    <td class="px-4 py-3 text-sm">
                                        <div class="font-medium text-gray-900">
                                            {{ incident.reporter?.firstName }} {{ incident.reporter?.lastName }}
                                        </div>
                                        <div class="text-xs text-gray-500">@{{ incident.reporter?.username }}</div>
                                    </td>

                                    <!-- Category -->
                                    <td class="px-4 py-3 text-sm">
                                        <span class="px-2 py-1 rounded-full text-xs font-medium" :class="categoryBadge(incident.category)">
                                            {{ formatCategory(incident.category) }}
                                        </span>
                                    </td>

                                    <!-- Trip ID -->
                                    <td class="px-4 py-3 text-sm text-gray-600">
                                        {{ incident.routeId || '-' }}
                                    </td>

                                    <!-- Status -->
                                    <td class="px-4 py-3 text-sm">
                                        <span class="px-2 py-1 rounded-full text-xs font-medium" :class="statusBadge(incident.status)">
                                            {{ formatStatus(incident.status) }}
                                        </span>
                                    </td>

                                    <!-- Date -->
                                    <td class="px-4 py-3 text-sm text-gray-600">
                                        {{ formatDate(incident.createdAt) }}
                                    </td>

                                    <!-- Actions -->
                                    <td class="px-4 py-3 text-sm">
                                        <div class="flex items-center gap-2">
                                            <!-- View Detail -->
                                            <button @click="navigateTo(`/admin/incidents/${incident.id}`)"
                                                class="p-2 text-gray-500 transition-colors cursor-pointer hover:text-blue-600"
                                                title="ดูรายละเอียด">
                                                <i class="text-lg fa-regular fa-eye"></i>
                                            </button>

                                            <!-- Assign (PENDING only) -->
                                            <button v-if="incident.status === 'PENDING'"
                                                @click="onAssign(incident)"
                                                class="p-2 text-gray-500 transition-colors cursor-pointer hover:text-yellow-600"
                                                title="รับเรื่อง">
                                                <i class="text-lg fa-solid fa-user-check"></i>
                                            </button>

                                            <!-- Resolve (UNDER_INVESTIGATION only) -->
                                            <button v-if="incident.status === 'UNDER_INVESTIGATION'"
                                                @click="openDecisionModal(incident, 'resolve')"
                                                class="p-2 text-gray-500 transition-colors cursor-pointer hover:text-green-600"
                                                title="จัดการเสร็จสิ้น">
                                                <i class="text-lg fa-solid fa-circle-check"></i>
                                            </button>

                                            <!-- Reject (PENDING or UNDER_INVESTIGATION) -->
                                            <button v-if="['PENDING', 'UNDER_INVESTIGATION'].includes(incident.status)"
                                                @click="openDecisionModal(incident, 'reject')"
                                                class="p-2 text-gray-500 transition-colors cursor-pointer hover:text-red-600"
                                                title="ปฏิเสธเคส">
                                                <i class="text-lg fa-solid fa-circle-xmark"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>

                                <tr v-if="!incidents.length && !isLoading">
                                    <td colspan="7" class="px-4 py-10 text-center text-gray-500">
                                        ไม่มีข้อมูล Incident
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <div class="flex flex-col gap-3 px-4 py-4 border-t border-gray-200 sm:px-6 sm:flex-row sm:items-center sm:justify-between">
                        <div class="flex flex-wrap items-center gap-3 text-sm">
                            <div class="flex items-center gap-2">
                                <span class="text-xs text-gray-500">Limit:</span>
                                <select v-model.number="pagination.limit" @change="applyFilters"
                                    class="px-2 py-1 text-sm border border-gray-300 rounded-md focus:ring-blue-500">
                                    <option :value="10">10</option>
                                    <option :value="20">20</option>
                                    <option :value="50">50</option>
                                </select>
                            </div>
                        </div>

                        <nav class="flex items-center gap-1">
                            <button class="px-3 py-2 text-sm border rounded-md disabled:opacity-50"
                                :disabled="pagination.page <= 1 || isLoading"
                                @click="changePage(pagination.page - 1)">
                                Previous
                            </button>

                            <template v-for="(p, idx) in pageButtons" :key="`p-${idx}-${p}`">
                                <span v-if="p === '…'" class="px-2 text-sm text-gray-500">…</span>
                                <button v-else class="px-3 py-2 text-sm border rounded-md"
                                    :class="p === pagination.page ? 'bg-blue-50 text-blue-600 border-blue-200' : 'hover:bg-gray-50'"
                                    :disabled="isLoading" @click="changePage(p)">
                                    {{ p }}
                                </button>
                            </template>

                            <button class="px-3 py-2 text-sm border rounded-md disabled:opacity-50"
                                :disabled="pagination.page >= totalPages || isLoading"
                                @click="changePage(pagination.page + 1)">
                                Next
                            </button>
                        </nav>
                    </div>
                </div>
            </div>
        </main>

        <!-- Decision Modal (Resolve / Reject) -->
        <div v-if="modal.show" class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
            <div class="bg-white rounded-lg shadow-xl w-full max-w-md mx-4 p-6">
                <h2 class="text-lg font-semibold text-gray-800 mb-4">
                    {{ modal.action === 'resolve' ? '✅ จัดการเสร็จสิ้น' : '❌ ปฏิเสธเคส' }}
                </h2>
                <p class="text-sm text-gray-600 mb-3">
                    Incident: <span class="font-mono">{{ modal.incident?.id?.slice(0, 8) }}...</span>
                </p>
                <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-1">Admin Notes</label>
                    <textarea v-model="modal.adminNotes" rows="4"
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
                        :placeholder="modal.action === 'resolve' ? 'บันทึกการดำเนินการ...' : 'เหตุผลที่ปฏิเสธ...'" />
                </div>
                <div class="flex justify-end gap-3">
                    <button @click="modal.show = false"
                        class="px-4 py-2 text-gray-700 border border-gray-300 rounded-md hover:bg-gray-50 cursor-pointer">
                        ยกเลิก
                    </button>
                    <button @click="confirmDecision"
                        :disabled="modal.submitting"
                        class="px-4 py-2 text-white rounded-md cursor-pointer disabled:opacity-50"
                        :class="modal.action === 'resolve' ? 'bg-green-600 hover:bg-green-700' : 'bg-red-600 hover:bg-red-700'">
                        {{ modal.submitting ? 'กำลังบันทึก...' : (modal.action === 'resolve' ? 'ยืนยัน Resolved' : 'ยืนยัน Rejected') }}
                    </button>
                </div>
            </div>
        </div>

        <!-- Mobile Overlay -->
        <div id="overlay" class="fixed inset-0 z-40 hidden bg-black bg-opacity-50 lg:hidden"
            @click="closeMobileSidebar"></div>
    </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, onUnmounted } from 'vue'
import { useRuntimeConfig, useCookie, navigateTo } from '#app'
import dayjs from 'dayjs'
import 'dayjs/locale/th'
import buddhistEra from 'dayjs/plugin/buddhistEra'
import AdminHeader from '~/components/admin/AdminHeader.vue'
import AdminSidebar from '~/components/admin/AdminSidebar.vue'
import { useToast } from '~/composables/useToast'

dayjs.locale('th')
dayjs.extend(buddhistEra)

definePageMeta({ middleware: ['admin-auth'] })

const { toast } = useToast()

// ─── State ───────────────────────────────────────────────────────────────────
const isLoading = ref(false)
const loadError = ref('')
const incidents = ref([])

const stats = reactive({
    total: 0,
    resolvedToday: 0,
    byStatus: {
        PENDING: 0,
        UNDER_INVESTIGATION: 0,
        RESOLVED: 0,
        REJECTED: 0
    }
})

const statusList = [
    { value: 'PENDING', label: 'Pending', color: 'text-blue-600' },
    { value: 'UNDER_INVESTIGATION', label: 'Under Investigation', color: 'text-yellow-600' },
    { value: 'RESOLVED', label: 'Resolved', color: 'text-green-600' },
    { value: 'REJECTED', label: 'Rejected', color: 'text-red-600' }
]

const pagination = reactive({
    page: 1,
    limit: 20,
    total: 0,
    totalPages: 1
})

const filters = reactive({
    q: '',
    status: '',
    category: '',
    sort: ''
})

// Modal state for resolve/reject
const modal = reactive({
    show: false,
    action: '',   // 'resolve' | 'reject'
    incident: null,
    adminNotes: '',
    submitting: false
})

// ─── Computed ─────────────────────────────────────────────────────────────────
const totalPages = computed(() =>
    Math.max(1, pagination.totalPages || Math.ceil((pagination.total || 0) / (pagination.limit || 20)))
)

const pageButtons = computed(() => {
    const total = totalPages.value
    const current = pagination.page
    if (!total || total < 1) return []
    if (total <= 5) return Array.from({ length: total }, (_, i) => i + 1)
    const set = new Set([1, total, current])
    if (current - 1 > 1) set.add(current - 1)
    if (current + 1 < total) set.add(current + 1)
    const pages = Array.from(set).sort((a, b) => a - b)
    const out = []
    for (let i = 0; i < pages.length; i++) {
        if (i > 0 && pages[i] - pages[i - 1] > 1) out.push('…')
        out.push(pages[i])
    }
    return out
})

const filteredIncidents = computed(() => {
    let data = [...incidents.value]

    if (filters.q) {
        const q = filters.q.toLowerCase()
        data = data.filter(inc =>
            inc.description?.toLowerCase().includes(q) ||
            inc.reporter?.username?.toLowerCase().includes(q) ||
            inc.reporter?.firstName?.toLowerCase().includes(q) ||
            inc.reporter?.lastName?.toLowerCase().includes(q)
        )
    }

    if (filters.status) {
        data = data.filter(inc => inc.status === filters.status)
    }

    if (filters.category) {
        data = data.filter(inc => inc.category === filters.category)
    }

    if (filters.sort) {
        const [field, order] = filters.sort.split(':')
        data.sort((a, b) => {
            const aVal = new Date(a[field] || 0)
            const bVal = new Date(b[field] || 0)
            return order === 'asc' ? aVal - bVal : bVal - aVal
        })
    }

    return data
})

// ─── Helpers ─────────────────────────────────────────────────────────────────
function statusBadge(status) {
    const map = {
        PENDING: 'bg-blue-100 text-blue-700',
        UNDER_INVESTIGATION: 'bg-yellow-100 text-yellow-700',
        RESOLVED: 'bg-green-100 text-green-700',
        REJECTED: 'bg-red-100 text-red-700'
    }
    return map[status] || 'bg-gray-100 text-gray-700'
}

function categoryBadge(category) {
    const map = {
        DANGEROUS_DRIVING: 'bg-red-100 text-red-700',
        AGGRESSIVE_BEHAVIOR: 'bg-orange-100 text-orange-700',
        HARASSMENT: 'bg-purple-100 text-purple-700',
        NO_SHOW: 'bg-yellow-100 text-yellow-700',
        FRAUD_OR_SCAM: 'bg-pink-100 text-pink-700',
        OTHER: 'bg-gray-100 text-gray-700'
    }
    return map[category] || 'bg-gray-100 text-gray-700'
}

function formatStatus(status) {
    const map = {
        PENDING: 'Pending',
        UNDER_INVESTIGATION: 'Under Investigation',
        RESOLVED: 'Resolved',
        REJECTED: 'Rejected'
    }
    return map[status] || status
}

function formatCategory(category) {
    const map = {
        DANGEROUS_DRIVING: 'Dangerous Driving',
        AGGRESSIVE_BEHAVIOR: 'Aggressive Behavior',
        HARASSMENT: 'Harassment',
        NO_SHOW: 'No Show',
        FRAUD_OR_SCAM: 'Fraud/Scam',
        OTHER: 'Other'
    }
    return map[category] || category
}

function formatDate(date) {
    if (!date) return '-'
    return dayjs(date).format('D MMM YYYY HH:mm')
}

// ─── API Calls ────────────────────────────────────────────────────────────────
async function fetchIncidents(page = 1) {
    const config = useRuntimeConfig()
    const token = useCookie('token').value

    isLoading.value = true
    loadError.value = ''

    try {
        const res = await $fetch('/incidents/admin/all', {
            baseURL: config.public.apiBase,
            headers: { Authorization: `Bearer ${token}` },
            query: {
                page,
                limit: pagination.limit,
                q: filters.q || undefined,
                status: filters.status || undefined,
                category: filters.category || undefined
            }
        })

        console.log('API RESPONSE:', res)

        incidents.value = res.data || res || []
        pagination.total = res.total || incidents.value.length
        pagination.page = page

        calculateStats()

    } catch (err) {
        console.error(err)
        loadError.value = 'โหลดข้อมูลไม่ได้'
    } finally {
        isLoading.value = false
    }
}

async function onAssign(incident) {
    const config = useRuntimeConfig()
    const token = useCookie('token').value

    try {
        await $fetch(`/incidents/admin/${incident.id}/assign`, {
            method: 'PATCH',
            baseURL: config.public.apiBase,
            headers: { Authorization: `Bearer ${token}` }
        })
        toast.success('รับเรื่องแล้ว', `Incident ${incident.id.slice(0, 8)} อยู่ระหว่างการสอบสวน`)
        await fetchIncidents(pagination.page)
    } catch (err) {
        console.error(err)
        toast.error('ไม่สำเร็จ', err?.data?.message || 'เกิดข้อผิดพลาด')
    }
}

function openDecisionModal(incident, action) {
    modal.incident = incident
    modal.action = action
    modal.adminNotes = ''
    modal.submitting = false
    modal.show = true
}

async function confirmDecision() {
    const config = useRuntimeConfig()
    const token = useCookie('token').value
    const { incident, action, adminNotes } = modal

    modal.submitting = true

    try {
        const endpoint = action === 'resolve'
            ? `/incidents/admin/${incident.id}/resolve`
            : `/incidents/admin/${incident.id}/reject`

        await $fetch(endpoint, {
            method: 'PATCH',
            baseURL: config.public.apiBase,
            headers: { Authorization: `Bearer ${token}` },
            body: { adminNotes }
        })

        const label = action === 'resolve' ? 'Resolved' : 'Rejected'
        toast.success(`${label} สำเร็จ`, `Incident ${incident.id.slice(0, 8)} ถูกอัปเดตแล้ว`)
        modal.show = false
        await fetchIncidents(pagination.page)
    } catch (err) {
        console.error(err)
        toast.error('ไม่สำเร็จ', err?.data?.message || 'เกิดข้อผิดพลาด')
    } finally {
        modal.submitting = false
    }
}

// ─── Stats ────────────────────────────────────────────────────────────────────
function calculateStats() {
    const data = incidents.value

    stats.total = data.length

    stats.byStatus = { PENDING: 0, UNDER_INVESTIGATION: 0, RESOLVED: 0, REJECTED: 0 }
    stats.resolvedToday = 0

    const today = dayjs().startOf('day')

    data.forEach(inc => {
        if (stats.byStatus[inc.status] !== undefined) {
            stats.byStatus[inc.status]++
        }
        if (inc.status === 'RESOLVED' && inc.resolvedAt) {
            if (dayjs(inc.resolvedAt).isAfter(today)) {
                stats.resolvedToday++
            }
        }
    })
}

// ─── Pagination & Filters ─────────────────────────────────────────────────────
function changePage(next) {
    if (next < 1 || next > totalPages.value) return
    fetchIncidents(next)
}

function applyFilters() {
    pagination.page = 1
    fetchIncidents(1)
}

function clearFilters() {
    filters.q = ''
    filters.status = ''
    filters.category = ''
    filters.sort = ''
    pagination.page = 1
    fetchIncidents(1)
}

function filterByStatus(status) {
    filters.status = filters.status === status ? '' : status
    applyFilters()
}

// ─── Sidebar Scripts ──────────────────────────────────────────────────────────
function closeMobileSidebar() {
    const sidebar = document.getElementById('sidebar')
    const overlay = document.getElementById('overlay')
    if (!sidebar || !overlay) return
    sidebar.classList.remove('mobile-open')
    overlay.classList.add('hidden')
}

function defineGlobalScripts() {
    window.toggleSidebar = function () {
        const sidebar = document.getElementById('sidebar')
        const mainContent = document.getElementById('main-content')
        const toggleIcon = document.getElementById('toggle-icon')
        if (!sidebar || !mainContent || !toggleIcon) return
        sidebar.classList.toggle('collapsed')
        if (sidebar.classList.contains('collapsed')) {
            mainContent.style.marginLeft = '80px'
            toggleIcon.classList.replace('fa-chevron-left', 'fa-chevron-right')
        } else {
            mainContent.style.marginLeft = '280px'
            toggleIcon.classList.replace('fa-chevron-right', 'fa-chevron-left')
        }
    }

    window.toggleMobileSidebar = function () {
        const sidebar = document.getElementById('sidebar')
        const overlay = document.getElementById('overlay')
        if (!sidebar || !overlay) return
        sidebar.classList.toggle('mobile-open')
        overlay.classList.toggle('hidden')
    }

    window.toggleSubmenu = function (menuId) {
        const menu = document.getElementById(menuId)
        const icon = document.getElementById(menuId + '-icon')
        if (!menu || !icon) return
        menu.classList.toggle('hidden')
        if (menu.classList.contains('hidden')) {
            icon.classList.replace('fa-chevron-up', 'fa-chevron-down')
        } else {
            icon.classList.replace('fa-chevron-down', 'fa-chevron-up')
        }
    }

    window.__adminResizeHandler__ = function () {
        const sidebar = document.getElementById('sidebar')
        const mainContent = document.getElementById('main-content')
        const overlay = document.getElementById('overlay')
        if (!sidebar || !mainContent || !overlay) return
        if (window.innerWidth >= 1024) {
            sidebar.classList.remove('mobile-open')
            overlay.classList.add('hidden')
            mainContent.style.marginLeft = sidebar.classList.contains('collapsed') ? '80px' : '280px'
        } else {
            mainContent.style.marginLeft = '0'
        }
    }

    window.addEventListener('resize', window.__adminResizeHandler__)
}

function cleanupGlobalScripts() {
    window.removeEventListener('resize', window.__adminResizeHandler__ || (() => { }))
    delete window.toggleSidebar
    delete window.toggleMobileSidebar
    delete window.closeMobileSidebar
    delete window.toggleSubmenu
    delete window.__adminResizeHandler__
}

// ─── Lifecycle ────────────────────────────────────────────────────────────────
useHead({
    title: 'Incident Management - Admin Dashboard',
    link: [{ rel: 'stylesheet', href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css' }]
})

onMounted(() => {
    defineGlobalScripts()
    if (typeof window.__adminResizeHandler__ === 'function') {
        window.__adminResizeHandler__()
    }
    fetchIncidents()
})

onUnmounted(() => {
    cleanupGlobalScripts()
})
</script>

<style scoped>
.sidebar {
    transition: width 0.3s ease;
}
.sidebar.collapsed { width: 80px; }
.sidebar:not(.collapsed) { width: 280px; }
.sidebar-item { transition: all 0.3s ease; }
.sidebar-item:hover { background-color: rgba(59, 130, 246, 0.05); }
.sidebar.collapsed .sidebar-text { display: none; }
.sidebar.collapsed .sidebar-item { justify-content: center; }
.main-content { transition: margin-left 0.3s ease; }

@media (max-width: 768px) {
    .sidebar {
        position: fixed;
        z-index: 1000;
        transform: translateX(-100%);
    }
    .sidebar.mobile-open { transform: translateX(0); }
    .main-content { margin-left: 0 !important; }
}
</style>
