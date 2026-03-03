<template>
    <div class="">
        <AdminHeader />
        <AdminSidebar />

        <!-- Main Content -->
        <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">
            <!-- Back -->
            <div class="mb-8">
                <NuxtLink to="/admin/reports-dashboard"
                    class="inline-flex items-center gap-2 px-3 py-2 border border-gray-300 rounded-md hover:bg-gray-50">
                    <i class="fa-solid fa-arrow-left"></i>
                    <span>ย้อนกลับ</span>
                </NuxtLink>
            </div>

            <!-- Page Title -->
            <div class="mx-auto max-w-8xl">
                <!-- Title + Controls -->
                <div class="flex flex-col gap-3 mb-6 sm:flex-row sm:items-center sm:justify-between">
                    <!-- Left: Title + Create Button -->
                    <div class="flex items-center gap-3">
                        <h1 class="text-2xl font-semibold text-gray-800">รายละเอียดการรายงาน</h1>
                    </div>
                </div>
            </div>

            <!-- Loading / Error -->
            <div v-if="isLoading" class="p-8 text-center text-gray-500">กำลังโหลดข้อมูล...</div>
            <div v-else-if="loadError" class="p-8 text-center text-red-600">
                {{ loadError }}
            </div>

            <!-- Card -->
            <div v-else class="bg-white border border-gray-300 rounded-lg shadow-sm overflow-hidden" >            
                <div class="grid grid-cols-1 lg:grid-cols-4">
                    <!-- ฝั่งซ้าย: แสดงข้อมูลการ Report -->
                    <div class="md:col-span-1 p-4 border-b md:border-b-0 md:border-r border-gray-300 bg-gray-50">
                        <!-- Report Detail -->
                        <div>
                            <p>
                                <span class="font-semibold">Report ID: </span>
                                <span class="text-gray-600">{{ report?.id }}</span>
                            </p>
                            <p>
                                <span class="font-semibold">Trip ID: </span>
                                <span class="text-gray-600">{{ report?.routeId }}</span>
                            </p>
                            <p>
                                <span class="font-semibold">Case Status ID : </span>
                                <span class="text-gray-600">{{ report?.routeId }}</span>
                            </p>
                            <p>
                                <span class="font-semibold">ผู้รับเรื่อง : </span>
                                <span class="text-gray-600">
                                    {{
                                    report?.resolvedBy
                                        ? report.resolvedBy.firstName + ' ' + report.resolvedBy.lastName
                                        : 'ยังไม่มีผู้รับเรื่อง'
                                    }}
                                </span>
                            </p>

                            <!-- ปุ่มรับเรื่อง -->
                            <button
                            @click="assignReport"
                            :disabled="assigning || report?.resolvedById"
                            :class="[
                                'w-full mt-4 py-2 rounded transition text-white',
                                report?.resolvedById
                                ? 'bg-gray-400 cursor-not-allowed'
                                : 'bg-green-600 hover:bg-green-700'
                            ]"
                            >
                                {{
                                    assigning
                                    ? 'กำลังรับเรื่อง...'
                                    : report?.resolvedById
                                        ? 'มีผู้รับเรื่องแล้ว'
                                        : 'รับเรื่อง'
                                }}
                            </button>
                        </div>

                        <div class="border-t border-gray-300 my-6"></div>

                        <!-- Report History -->
                        <div>
                            <p class="font-semibold mb-2">Report History</p>
                            <div>
                                <p>
                                    <span class="font-semibold">สร้างเมื่อ : </span>
                                    <span class="text-gray-600">{{ formatDateTime(report?.createdAt) }}</span>
                                </p>
                                <p>
                                    <span class="font-semibold">แก้ไขเมื่อ : </span>
                                    <span class="text-gray-600">{{ formatDateTime(report?.updatedAt) }}</span>
                                </p>
                                <p>
                                    <span class="font-semibold">ดำเนินการเสร็จสิ้นเมื่อ : </span>
                                    <span class="text-gray-600">{{ formatDateTime(report?.resolvedAt) }}</span>
                                </p>
                                <p>
                                    <span class="font-semibold">ปิดเคสเมื่อ : </span>
                                    <span class="text-gray-600">{{ formatDateTime(report?.closedAt) }}</span>
                                </p>
                                <button
                                class="px-4 py-2 text-white bg-gray-700 rounded-md hover:bg-gray-800 disabled:bg-gray-400"
                                :disabled="report?.status !== 'RESOLVED' && report?.status !== 'REJECTED'"
                                @click="closeReport"
                                >
                                    ปิดเคส
                                </button>
                            </div>
                        </div>

                        <!-- <div class="border-t border-gray-300 my-6"></div> -->

                        <!-- Export to PDF button -->
                        <!-- <button class="w-full mt-4 bg-blue-500 hover:bg-blue-600 text-white py-2 rounded">
                            Export to PDF
                        </button> -->

                    </div>
                    
                    <!-- ฝั่งขวา: แสดงรายละเอียดการ Report -->
                    <div class="lg:col-span-3 p-6 space-y-6">
                        <div>
                            <p>
                                <span class="font-semibold">หัวข้อ : </span>
                                <span class="text-gray-600">
                                {{ formatCategory(report?.category) }}
                                </span>
                            </p>
                            <p>
                                <span class="font-semibold">ผู้ใช้ที่แจ้งรายงาน : </span>
                                <span class="text-gray-600">
                                    {{ report?.reporter?.firstName }} {{ report?.reporter?.lastName }}
                                </span>
                            </p>
                            <p>
                                <span class="font-semibold">สถานะการรายงาน : </span>
                                <span class="text-gray-600">
                                    {{ report?.status }}
                                </span>
                            </p>
                        </div>
                        <div class="border-t border-gray-300 my-6"></div>
                        <div>
                            <span class="font-semibold">รายชื่อผู้ขับและผู้โดยสารทั้งหมด </span>
                        </div>
                        <div>
                            <table class="min-w-full divide-y divide-gray-200">
                                <thead class="bg-gray-50">
                                    <tr>
                                        <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">ชื่อ-นามสกุล</th>
                                        <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">สถานะการโดนแบน</th>
                                    </tr>
                                </thead>
                                <tbody class="bg-white divide-y divide-gray-200">
                                    <tr v-if="report?.route?.driver">
                                        <td class="px-4 py-3">
                                            <span class="inline-flex items-center px-2 py-1 mr-2 text-xs font-medium text-blue-700 bg-blue-100 rounded-full">คนขับ</span>
                                            {{ report.route.driver.firstName }} {{ report.route.driver.lastName }}
                                        </td>
                                        <td class="px-4 py-3">
                                            <span :class="statusClass(report.route.driver)">
                                                {{ getDisciplinaryStatus(report.route.driver).label }}
                                            </span>
                                        </td>
                                    </tr>

                                    <tr
                                        v-for="passenger in uniquePassengers"
                                        :key="passenger.id"
                                    >
                                        <td class="px-4 py-3">
                                            <span class="inline-flex items-center px-2 py-1 mr-2 text-xs font-medium text-green-700 bg-green-100 rounded-full">ผู้โดยสาร</span>
                                            {{ passenger.firstName }} {{ passenger.lastName }}
                                        </td>
                                        <td class="px-4 py-3">
                                            <span :class="statusClass(passenger)">
                                                {{ getDisciplinaryStatus(passenger).label }}
                                            </span>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                        <div>
                            <p>
                                <span class="font-semibold">รายละเอียด : </span>
                                <span class="text-gray-600">
                                    {{ report.description }}
                                </span>
                            </p>
                            
                            <!-- แสดงไฟล์แนบ -->
                            <p class="font-semibold">ไฟล์แนบ:</p>
                                <div
                                v-if="report?.evidences?.length"
                                class="grid grid-cols-1 gap-6 sm:grid-cols-2 mt-4"
                                >
                                <div
                                    v-for="file in report.evidences"
                                    :key="file.id"
                                    class="p-4 border-2 border-gray-300 border-dashed rounded-md"
                                >

                                    <!-- 🖼 IMAGE -->
                                    <img
                                    v-if="file.mimeType?.startsWith('image/')"
                                    :src="file.url"
                                    class="w-full rounded max-h-96 object-contain"
                                    />

                                    <!-- 🎥 VIDEO -->
                                    <video
                                    v-else-if="file.mimeType?.startsWith('video/')"
                                    :src="file.url"
                                    controls
                                    class="w-full rounded max-h-96"
                                    />

                                    <!-- 🎵 AUDIO -->
                                    <audio
                                    v-else-if="file.mimeType?.startsWith('audio/')"
                                    :src="file.url"
                                    controls
                                    class="w-full"
                                    />

                                    <!-- 📄 PDF -->
                                    <iframe
                                    v-else-if="file.mimeType === 'application/pdf'"
                                    :src="file.url"
                                    class="w-full h-96 rounded"
                                    ></iframe>

                                    <!-- ❗ Other -->
                                    <div v-else class="text-center text-gray-500">
                                    <i class="text-3xl fa-regular fa-file"></i>
                                    <p class="mt-2 text-sm">
                                        {{ file.fileName || 'ไฟล์ไม่รองรับการแสดงผล' }}
                                    </p>
                                    </div>

                                </div>
                                </div>

                                <p v-else class="text-gray-500 mt-2">
                                ไม่มีไฟล์แนบ
                                </p>

                        </div>
                        <button
                        class="w-full mt-4 bg-blue-500 hover:bg-blue-600 text-white py-2 rounded"
                        @click="showManageSection = !showManageSection"
                        >
                            {{ showManageSection ? 'ปิดการจัดการ' : 'จัดการ' }}
                        </button>
                    </div>
                </div>

                <div v-if="showManageSection" class="mt-8">
                    <div class="bg-white border border-gray-300 rounded-lg shadow-sm overflow-hidden">

                        <!-- Header -->
                        <div class="px-6 py-4 bg-gray-50">
                            <h3 class="text-lg font-semibold text-gray-800">
                                จัดการเคส
                            </h3>
                        </div>

                        <div class="p-6 space-y-6">
                        <!-- ตารางเลือกแจกใบเหลือง -->
                            <div>
                                <table class="min-w-full divide-y divide-gray-200">
                                <thead class="bg-gray-50">
                                    <tr>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">
                                        เลือก
                                    </th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">
                                        ชื่อ-นามสกุล
                                    </th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">
                                        สถานะปัจจุบัน
                                    </th>
                                    </tr>
                                </thead>

                                <tbody class="bg-white divide-y divide-gray-200">

                                    <!-- แสดงรายการผู้ใช้ที่ไม่ซ้ำกัน -->
                                    <tr
                                    v-for="user in uniqueUsers"
                                    :key="user.id"
                                    >
                                    <td class="px-4 py-3">
                                        <input
                                        type="checkbox"
                                        :value="user.id"
                                        v-model="selectedUsers"
                                        class="w-4 h-4 text-yellow-600 border-gray-300 rounded"
                                        />
                                    </td>
                                    <td class="px-4 py-3 font-medium text-gray-900">
                                        {{ user.firstName }}
                                        {{ user.lastName }}
                                    </td>
                                    <td class="px-4 py-3">
                                        <span :class="statusClass(user)">
                                        {{ getDisciplinaryStatus(user).label }}
                                        </span>
                                    </td>
                                    </tr>

                                </tbody>
                                </table>
                            </div>

                            <!-- Admin Comment -->
                            <div>
                                <label class="block mb-2 text-sm font-medium text-gray-700">
                                เหตุผลจากผู้ดูแลระบบ
                                </label>
                                <textarea
                                v-model="adminComment"
                                rows="3"
                                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none"
                                placeholder="ระบุเหตุผลในการดำเนินการ..."
                                ></textarea>
                            </div>

                            <!-- เลือกข้อความแจ้งเตือน -->
                            <div>
                                <label class="block mb-2 text-sm font-medium text-gray-700">
                                แจ้งเตือนกลับไปยังผู้แจ้ง
                                </label>
                                <select
                                v-model="selectedPreset"
                                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:outline-none"
                                >
                                <option value="">เลือกข้อความแจ้งเตือน</option>
                                <option value="RESOLVED">เคสได้รับการดำเนินการแล้ว</option>
                                <option value="WARNING_ISSUED">ได้ทำการมอบใบเหลืองแล้ว</option>
                                </select>
                            </div>
                            <!-- Action Buttons -->
                            <div class="flex justify-end gap-3 pt-4">

                                <button
                                class="px-4 py-2 text-gray-600 border border-gray-300 rounded-md hover:bg-gray-100"
                                @click="showManageSection = false"
                                >
                                    ยกเลิก
                                </button>

                                <button
                                class="px-4 py-2 text-white bg-red-500 rounded-md hover:bg-red-600"
                                @click="rejectReport"
                                >
                                    ปฏิเสธเคส
                                </button>

                                <button
                                class="px-4 py-2 text-white bg-yellow-500 rounded-md hover:bg-yellow-600 disabled:bg-gray-400"
                                :disabled="!selectedUsers.length"
                                @click="issueYellowCard"
                                >
                                    มอบใบเหลือง
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRoute, useRuntimeConfig, useCookie } from '#app'
import AdminHeader from '~/components/admin/AdminHeader.vue'
import AdminSidebar from '~/components/admin/AdminSidebar.vue'
import { useToast } from '~/composables/useToast'
import dayjs from 'dayjs'
import 'dayjs/locale/th'
import { computed } from 'vue'

dayjs.locale('th')
definePageMeta({ middleware: ['admin-auth'] })
useHead({
    title: 'ดูรายละเอียดการรายงาน • Admin',
    link: [{ rel: 'stylesheet', href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css' }]
})

const route = useRoute()
const { toast } = useToast()

const isLoading = ref(true)
const loadError = ref('')
const report = ref(null)
const assigning = ref(false)
const currentAdmin = ref(null)

const showManageSection = ref(false)
const selectedUsers = ref([])
const adminComment = ref('')
const selectedPreset = ref('')

const uniquePassengers = computed(() => {
  if (!report.value?.route?.bookings) return []
  
  const passengers = []
  const seen = new Set()

  report.value.route.bookings.forEach(booking => {
    if (booking.passenger && !seen.has(booking.passenger.id)) {
      seen.add(booking.passenger.id)
      passengers.push(booking.passenger)
    }
  })

  return passengers
})

// คำนวณรายการผู้ใช้ที่ถูกรายงานเท่านั้น (แสดงเฉพาะคนที่ถูก report จริงๆ)
const uniqueUsers = computed(() => {
  console.log("🟡 [FRONTEND DEBUG] กำลังคำนวณ uniqueUsers, ข้อมูลต้นทาง:", report.value);

  if (!report.value) return [];
  
  if (report.value.reportedUsers && report.value.reportedUsers.length > 0) {
    console.log("🟡 [FRONTEND DEBUG] เข้าเงื่อนไขที่ 1 (แบบ Group มีหลายคน):", report.value.reportedUsers.length, "คน");
    return report.value.reportedUsers.map(user => ({
      id: user.id,
      firstName: user.firstName,
      lastName: user.lastName,
      ...user
    }));
  }
  
  if (report.value.driver) {
    console.log("🟡 [FRONTEND DEBUG] เข้าเงื่อนไขที่ 2 (แบบเดี่ยว / ของเก่า): 1 คน");
    return [{
      id: report.value.driver.id,
      firstName: report.value.driver.firstName,
      lastName: report.value.driver.lastName,
      ...report.value.driver
    }];
  }
  
  console.log("🟡 [FRONTEND DEBUG] หาใครไม่เจอเลย คืนค่า Array ว่าง");
  return [];
});

const formatDateTime = (date) => {
  if (!date) return '-'

  return dayjs(date)
    .locale('th')
    .format('D MMMM YYYY เวลา HH:mm น.')
}

const getDisciplinaryStatus = (u) => {
  if (!u) return { label: '-', color: 'gray' }

  const now = dayjs()

  if (
    (u.driverSuspendedUntil && dayjs(u.driverSuspendedUntil).isAfter(now)) ||
    (u.passengerSuspendedUntil && dayjs(u.passengerSuspendedUntil).isAfter(now))
  ) {
    return { label: 'แดง (ถูกแบน)', color: 'red' }
  }

  if (u.yellowCardCount > 0) {
    return { label: `ใบเหลือง ${u.yellowCardCount} ใบ`, color: 'yellow' }
  }

  return { label: 'ไม่มี', color: 'gray' }
}

const statusClass = (u) => {
  const status = getDisciplinaryStatus(u)

  return {
    'text-red-600 font-semibold': status.color === 'red',
    'text-yellow-600 font-semibold': status.color === 'yellow',
    'text-gray-500': status.color === 'gray'
  }
}

const formatCategory = (category) => {
    if (!category) return '-'

    return category
        .toLowerCase()
        .replace(/_/g, ' ')
        .replace(/\b\w/g, char => char.toUpperCase())
}

const assignReport = async () => {
    try {
        assigning.value = true

        const config = useRuntimeConfig()
        const token = useCookie('token')

        await $fetch(`/reports/admin/${report.value.id}/assign`, {
        method: 'PATCH',
        baseURL: config.public.apiBase,
        headers: {
            Authorization: `Bearer ${token.value}`
        }
        })

        await fetchReport()  // reload ข้อมูลใหม่

        toast.success('รับเรื่องเรียบร้อย')

    } catch (err) {
        console.error(err)
        toast.error('ไม่สามารถรับเรื่องได้')
    } finally {
        assigning.value = false
    }
}

const fetchCurrentAdmin = async () => {
    const config = useRuntimeConfig()
    const token = useCookie('token')

    const res = await $fetch('/auth/me', {
    baseURL: config.public.apiBase,
    headers: {
        Authorization: `Bearer ${token.value}`
    }
    })
    currentAdmin.value = res
}

const issueYellowCard = async () => {
    if (!selectedUsers.value.length) {
        toast.error('กรุณาเลือกผู้ใช้')
        return
    }

    try {
        const config = useRuntimeConfig()
        const token = useCookie('token')

        await $fetch(`/reports/admin/${report.value.id}/issue-yellow`, {
        method: 'POST',
        baseURL: config.public.apiBase,
        headers: {
            Authorization: `Bearer ${token.value}`
        },
        body: {
            userIds: selectedUsers.value,
            adminComment: adminComment.value,
            notificationType: selectedPreset.value
        }
        })

        toast.success('มอบใบเหลืองเรียบร้อย')
        selectedUsers.value = []
        adminComment.value = ''
        selectedPreset.value = ''

        console.log('selectedUsers:', selectedUsers.value)

        await fetchReport()

    } catch (err) {
        console.error('ISSUE YELLOW ERROR:', err)
        toast.error('ไม่สามารถมอบใบเหลืองได้')
    }
}

const rejectReport = async () => {
    try {
        const config = useRuntimeConfig()
        const token = useCookie('token')

        await $fetch(`/reports/admin/${report.value.id}/status`, {
        method: 'PATCH',
        baseURL: config.public.apiBase,
        headers: {
            Authorization: `Bearer ${token.value}`
        },
        body: {
            status: 'REJECTED',
            adminNotes: adminComment.value || 'เคสถูกปฏิเสธ'
        }
        })

        toast.success('ปฏิเสธเคสเรียบร้อย')
        adminComment.value = ''
        showManageSection.value = false

        await fetchReport()

    } catch (err) {
        console.error(err)
        toast.error('ไม่สามารถปฏิเสธเคสได้')
    }
    }

const closeReport = async () => {
    try {
        const config = useRuntimeConfig()
        const token = useCookie('token')

        await $fetch(`/reports/admin/${report.value.id}/status`, {
        method: 'PATCH',
        baseURL: config.public.apiBase,
        headers: {
            Authorization: `Bearer ${token.value}`
        },
        body: {
            status: 'CLOSED',
            adminNotes: adminComment.value || 'เคสถูกปิดแล้ว'
        }
        })

        toast.success('ปิดเคสเรียบร้อย')
        showManageSection.value = false

        await fetchReport()

    } catch (err) {
        console.error(err)
        toast.error('ไม่สามารถปิดเคสได้')
    }
    }
    
async function fetchReport() {
    const config = useRuntimeConfig()
    const token = useCookie('token')

    if (!token.value) {
        loadError.value = 'กรุณาเข้าสู่ระบบก่อนใช้งาน'
        return
    }

    isLoading.value = true
    loadError.value = ''

    try {
        const id = route.params.id

        const res = await $fetch(`/reports/${id}`, {
            baseURL: config.public.apiBase,
            headers: {
                Accept: 'application/json',
                Authorization: `Bearer ${token.value}`
            }
        })

        console.log("🟢 [FRONTEND DEBUG] Response จาก API:", res);
        console.log("🟢 [FRONTEND DEBUG] res.reportedUsers:", res.reportedUsers);

        report.value = res

    } catch (err) {
        console.error(err)
        loadError.value = err?.data?.message || 'ไม่สามารถโหลดข้อมูลได้'
        toast.error('เกิดข้อผิดพลาด')
    } finally {
        isLoading.value = false
    }
}

function defineGlobalScripts() {
    window.__adminResizeHandler__ = function () {
        const sidebar = document.getElementById('sidebar')
        const mainContent = document.getElementById('main-content')
        const overlay = document.getElementById('overlay')
        if (!sidebar || !mainContent || !overlay) return
        if (window.innerWidth >= 1024) {
            sidebar.classList.remove('mobile-open'); overlay.classList.add('hidden')
            mainContent.style.marginLeft = sidebar.classList.contains('collapsed') ? '80px' : '280px'
        } else {
            mainContent.style.marginLeft = '0'
        }
    }
    window.addEventListener('resize', window.__adminResizeHandler__)
}

function cleanupGlobalScripts() {
    window.removeEventListener('resize', window.__adminResizeHandler__ || (() => { }))
    delete window.__adminResizeHandler__
}

onMounted(async () => {
    defineGlobalScripts()
    if (typeof window.__adminResizeHandler__ === 'function')
        window.__adminResizeHandler__()

    await fetchReport()
    await fetchCurrentAdmin()
})

onUnmounted(() => cleanupGlobalScripts())
</script>