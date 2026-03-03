<template>
  <div class="kanit-font bg-gray-50">
    <!-- Scroll Progress Indicator -->
    <div class="scroll-indicator">
      <div class="scroll-progress" ref="scrollProgressEl"></div>
    </div>

    <div class="px-4 py-8 mx-auto max-w-7xl sm:px-6 lg:px-8">
      <div class="grid grid-cols-1 gap-8 lg:grid-cols-4">
        <!-- Table of Contents (Sidebar) -->
        <div class="lg:col-span-1">
          <div class="sticky p-6 bg-white rounded-lg shadow-md top-24">
            <h3 class="mb-4 text-lg font-semibold text-gray-900">สารบัญ</h3>
            <nav class="space-y-2">
              <a
                href="#section-1"
                class="block px-3 py-2 text-sm text-gray-600 rounded-md toc-link hover:text-blue-600"
              >
                1. บทนำ
              </a>
              <a
                href="#section-2"
                class="block px-3 py-2 text-sm text-gray-600 rounded-md toc-link hover:text-blue-600"
              >
                2. คำจำกัดความ
              </a>
              <a
                href="#section-3"
                class="block px-3 py-2 text-sm text-gray-600 rounded-md toc-link hover:text-blue-600"
              >
                3. ขอบเขตและลักษณะของบริการ
              </a>
              <a
                href="#section-4"
                class="block px-3 py-2 text-sm text-gray-600 rounded-md toc-link hover:text-blue-600"
              >
                4. การสมัครสมาชิกและบัญชีผู้ใช้
              </a>
              <a
                href="#section-5"
                class="block px-3 py-2 text-sm text-gray-600 rounded-md toc-link hover:text-blue-600"
              >
                5. หน้าที่และความรับผิดชอบ
              </a>
              <a
                href="#section-6"
                class="block px-3 py-2 text-sm text-gray-600 rounded-md toc-link hover:text-blue-600"
              >
                6. การชำระเงิน
              </a>
              <a
                href="#section-7"
                class="block px-3 py-2 text-sm text-gray-600 rounded-md toc-link hover:text-blue-600"
              >
                7. ระบบการให้คะแนนและรีวิว
              </a>
              <a
                href="#section-8"
                class="block px-3 py-2 text-sm text-gray-600 rounded-md toc-link hover:text-blue-600"
              >
                8. ข้อจำกัดความรับผิด
              </a>
              <a
                href="#section-9"
                class="block px-3 py-2 text-sm text-gray-600 rounded-md toc-link hover:text-blue-600"
              >
                9. ทรัพย์สินทางปัญญา
              </a>
              <a
                href="#section-10"
                class="block px-3 py-2 text-sm text-gray-600 rounded-md toc-link hover:text-blue-600"
              >
                10. การระงับและยกเลิกบัญชี
              </a>
              <a
                href="#section-11"
                class="block px-3 py-2 text-sm text-gray-600 rounded-md toc-link hover:text-blue-600"
              >
                11. การแก้ไขเปลี่ยนแปลง
              </a>
              <a
                href="#section-12"
                class="block px-3 py-2 text-sm text-gray-600 rounded-md toc-link hover:text-blue-600"
              >
                12. กฎหมายที่ใช้บังคับ
              </a>
              <a
                href="#section-13"
                class="block px-3 py-2 text-sm text-gray-600 rounded-md toc-link hover:text-blue-600"
              >
                13. การติดต่อ
              </a>
            </nav>
          </div>
        </div>

        <!-- Main Content -->
        <div class="lg:col-span-3">
          <!-- Header Section -->
          <div class="p-8 mb-8 bg-white rounded-lg shadow-md">
            <h1 class="mb-4 text-3xl font-bold text-gray-900">
              ข้อตกลงและเงื่อนไขการใช้บริการ
            </h1>
            <p class="mb-6 text-lg text-gray-600">(Terms of Service)</p>

            <div class="p-6 rounded-lg highlight-box">
              <div class="flex items-center mb-2">
                <svg
                  class="w-6 h-6 mr-2 text-blue-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                  />
                </svg>
                <span class="text-lg font-semibold text-blue-900">
                  มีผลบังคับใช้ตั้งแต่วันที่: 8 กรกฎาคม 2568
                </span>
              </div>
              <p class="text-sm text-gray-700">
                การใช้บริการของเราถือว่าท่านได้อ่านและยอมรับข้อตกลงนี้แล้ว
              </p>
            </div>
          </div>

          <!-- Section 1: บทนำ -->
          <section
            id="section-1"
            class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card"
          >
            <h2 class="mb-4 text-2xl font-bold text-gray-900">ข้อ 1: บทนำ</h2>
            <p class="mb-4 leading-relaxed text-gray-700">
              ยินดีต้อนรับสู่ "ไปนำแหน่" ("แพลตฟอร์ม")
              ข้อตกลงและเงื่อนไขการใช้บริการนี้ ("ข้อตกลง")
              ถือเป็นสัญญาระหว่างท่าน ("ผู้ใช้") และแพลตฟอร์ม "ไปนำแหน่"
              การที่ท่านได้ลงทะเบียน เข้าสู่ระบบ และใช้งานบริการของเรา
              ถือว่าท่านได้อ่าน ทำความเข้าใจ
              และยอมรับข้อตกลงทั้งหมดนี้โดยสมบูรณ์แล้ว
            </p>
            <div class="p-4 border-l-4 border-red-400 rounded-r-lg bg-red-50">
              <p class="font-medium text-red-700">
                หากท่านไม่ยอมรับข้อตกลงนี้
                กรุณายุติการใช้งานแพลตฟอร์มของเราทันที
              </p>
            </div>
          </section>

          <!-- Section 2: คำจำกัดความ -->
          <section
            id="section-2"
            class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card"
          >
            <h2 class="mb-4 text-2xl font-bold text-gray-900">
              ข้อ 2: คำจำกัดความ
            </h2>
            <div class="space-y-4">
              <div class="pl-4 border-l-4 border-blue-400">
                <h3 class="font-semibold text-gray-900">"แพลตฟอร์ม"</h3>
                <p class="text-gray-700">
                  หมายถึง เว็บแอปพลิเคชัน "ไปนำแหน่" และบริการอื่นๆ
                  ที่เกี่ยวข้อง
                </p>
              </div>
              <div class="pl-4 border-l-4 border-green-400">
                <h3 class="font-semibold text-gray-900">"บริการ"</h3>
                <p class="text-gray-700">
                  หมายถึง
                  การที่แพลตฟอร์มทำหน้าที่เป็นตัวกลางทางเทคโนโลยีเพื่อเชื่อมต่อระหว่าง
                  "ผู้ขับขี่" และ "ผู้โดยสาร"
                  ที่มีความต้องการเดินทางในเส้นทางเดียวกันหรือใกล้เคียงกัน
                </p>
              </div>
              <div class="pl-4 border-l-4 border-purple-400">
                <h3 class="font-semibold text-gray-900">"ผู้ใช้"</h3>
                <p class="text-gray-700">
                  หมายถึง บุคคลทั่วไปที่ลงทะเบียนและสร้างบัญชีบนแพลตฟอร์ม
                  ไม่ว่าจะในฐานะผู้โดยสารหรือผู้ขับขี่
                </p>
              </div>
              <div class="pl-4 border-l-4 border-orange-400">
                <h3 class="font-semibold text-gray-900">
                  "ผู้ขับขี่" (Driver)
                </h3>
                <p class="text-gray-700">
                  หมายถึง
                  ผู้ใช้ที่ลงทะเบียนบนแพลตฟอร์มเพื่อเสนอเส้นทางการเดินทางและแบ่งปันที่นั่งว่างในยานพาหนะส่วนตัวของตน
                </p>
              </div>
              <div class="pl-4 border-l-4 border-teal-400">
                <h3 class="font-semibold text-gray-900">
                  "ผู้โดยสาร" (Passenger)
                </h3>
                <p class="text-gray-700">
                  หมายถึง
                  ผู้ใช้ที่ใช้งานแพลตฟอร์มเพื่อค้นหาและทำการจองการเดินทางร่วมกับผู้ขับขี่
                </p>
              </div>
            </div>
          </section>

          <!-- Section 3: ขอบเขตและลักษณะของบริการ -->
          <section
            id="section-3"
            class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card"
          >
            <h2 class="mb-4 text-2xl font-bold text-gray-900">
              ข้อ 3: ขอบเขตและลักษณะของบริการ
            </h2>
            <div class="space-y-4">
              <div class="p-4 rounded-lg bg-blue-50">
                <h3 class="mb-2 font-semibold text-blue-900">3.1</h3>
                <p class="text-gray-700">
                  "ไปนำแหน่"
                  เป็นเพียงแพลตฟอร์มเทคโนโลยีที่ทำหน้าที่เป็นตัวกลางในการจับคู่เท่านั้น
                  เราไม่ได้เป็นผู้ให้บริการขนส่ง, ไม่ได้เป็นนายจ้างของผู้ขับขี่,
                  ไม่ได้เป็นเจ้าของหรือผู้ควบคุมยานพาหนะ
                  และไม่ได้เสนอบริการเดินทางโดยตรง
                </p>
              </div>
              <div class="p-4 rounded-lg bg-yellow-50">
                <h3 class="mb-2 font-semibold text-yellow-900">3.2</h3>
                <p class="text-gray-700">
                  สัญญาหรือข้อตกลงใดๆ
                  ที่เกี่ยวกับการเดินทางถือเป็นข้อตกลงโดยตรงระหว่างผู้ขับขี่และผู้โดยสาร
                  "ไปนำแหน่" ไม่มีส่วนรับผิดชอบในข้อตกลงหรือการกระทำใดๆ
                  ที่เกิดขึ้นระหว่างผู้ใช้
                </p>
              </div>
            </div>
          </section>

          <!-- Section 4: การสมัครสมาชิกและบัญชีผู้ใช้ -->
          <section
            id="section-4"
            class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card"
          >
            <h2 class="mb-4 text-2xl font-bold text-gray-900">
              ข้อ 4: การสมัครสมาชิกและบัญชีผู้ใช้
            </h2>
            <div class="space-y-4">
              <div class="flex items-start">
                <span
                  class="bg-blue-100 text-blue-800 text-sm font-semibold mr-3 px-2.5 py-0.5 rounded"
                  >4.1</span
                >
                <p class="text-gray-700">
                  ในการใช้บริการ
                  ท่านต้องลงทะเบียนสร้างบัญชีผู้ใช้และให้ข้อมูลที่เป็นจริง
                  ถูกต้อง และเป็นปัจจุบัน
                </p>
              </div>
              <div class="flex items-start">
                <span
                  class="bg-blue-100 text-blue-800 text-sm font-semibold mr-3 px-2.5 py-0.5 rounded"
                  >4.2</span
                >
                <p class="text-gray-700">
                  ท่านต้องมีอายุครบตามที่กฎหมายกำหนดในการทำนิติกรรมสัญญา
                  และมีความสามารถในการขับขี่ยานพาหนะตามกฎหมาย
                  (กรณีเป็นผู้ขับขี่)
                </p>
              </div>
              <div class="flex items-start">
                <span
                  class="bg-blue-100 text-blue-800 text-sm font-semibold mr-3 px-2.5 py-0.5 rounded"
                  >4.3</span
                >
                <p class="text-gray-700">
                  แพลตฟอร์มมีกระบวนการยืนยันตัวตนผ่านรหัส OTP
                  และอาจร้องขอเอกสารเพิ่มเติม เช่น บัตรประชาชน
                  เพื่อความปลอดภัยและความน่าเชื่อถือของชุมชนผู้ใช้
                </p>
              </div>
              <div class="flex items-start">
                <span
                  class="bg-blue-100 text-blue-800 text-sm font-semibold mr-3 px-2.5 py-0.5 rounded"
                  >4.4</span
                >
                <p class="text-gray-700">
                  ท่านมีหน้าที่รับผิดชอบในการรักษารหัสผ่านและข้อมูลบัญชีของท่านให้เป็นความลับ
                  และท่านต้องรับผิดชอบต่อกิจกรรมทั้งหมดที่เกิดขึ้นภายใต้บัญชีของท่าน
                </p>
              </div>
            </div>
          </section>

          <!-- Section 5: หน้าที่และความรับผิดชอบของผู้ใช้ -->
          <section
            id="section-5"
            class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card"
          >
            <h2 class="mb-4 text-2xl font-bold text-gray-900">
              ข้อ 5: หน้าที่และความรับผิดชอบของผู้ใช้
            </h2>

            <div class="space-y-6">
              <div class="p-6 rounded-lg bg-gray-50">
                <h3 class="mb-3 text-lg font-semibold text-gray-900">
                  5.1 สำหรับผู้ใช้ทุกคน:
                </h3>
                <ul class="space-y-2 text-gray-700">
                  <li class="flex items-start">
                    <span class="mr-2 text-blue-500">•</span>
                    <span
                      >ต้องปฏิบัติต่อผู้ใช้อื่นด้วยความเคารพและให้เกียรติ</span
                    >
                  </li>
                  <li class="flex items-start">
                    <span class="mr-2 text-blue-500">•</span>
                    <span
                      >ห้ามใช้แพลตฟอร์มในการกระทำที่ผิดกฎหมาย, ฉ้อโกง, คุกคาม
                      หรือสร้างความเดือดร้อนรำคาญ</span
                    >
                  </li>
                  <li class="flex items-start">
                    <span class="mr-2 text-blue-500">•</span>
                    <span
                      >ต้องใช้ระบบการให้คะแนนและรีวิวตามความเป็นจริงและอย่างสร้างสรรค์</span
                    >
                  </li>
                </ul>
              </div>

              <div class="p-6 rounded-lg bg-green-50">
                <h3 class="mb-3 text-lg font-semibold text-green-900">
                  5.2 สำหรับผู้โดยสาร (Passenger):
                </h3>
                <ul class="space-y-2 text-gray-700">
                  <li class="flex items-start">
                    <span class="mr-2 text-green-500">•</span>
                    <span
                      >ต้องให้ข้อมูลจุดนัดพบและจุดหมายปลายทางที่ถูกต้อง</span
                    >
                  </li>
                  <li class="flex items-start">
                    <span class="mr-2 text-green-500">•</span>
                    <span>ต้องตรงต่อเวลาตามที่ได้นัดหมายไว้กับผู้ขับขี่</span>
                  </li>
                  <li class="flex items-start">
                    <span class="mr-2 text-green-500">•</span>
                    <span>ต้องรับผิดชอบค่าเดินทางตามที่ได้ตกลงกันไว้</span>
                  </li>
                  <li class="flex items-start">
                    <span class="mr-2 text-green-500">•</span>
                    <span>มีหน้าที่ดูแลทรัพย์สินส่วนตัวของตนเอง</span>
                  </li>
                  <li class="flex items-start">
                    <span class="mr-2 text-green-500">•</span>
                    <span
                      >มีสิทธิ์ในการยกเลิกการจองตามเงื่อนไขที่แพลตฟอร์มกำหนด</span
                    >
                  </li>
                </ul>
              </div>

              <div class="p-6 rounded-lg bg-orange-50">
                <h3 class="mb-3 text-lg font-semibold text-orange-900">
                  5.3 สำหรับผู้ขับขี่ (Driver):
                </h3>
                <ul class="space-y-2 text-gray-700">
                  <li class="flex items-start">
                    <span class="mr-2 text-orange-500">•</span>
                    <span
                      >ต้องมีใบอนุญาตขับขี่ที่ยังไม่หมดอายุ,
                      เอกสารจดทะเบียนรถยนต์ และประกันภัยภาคบังคับ (พ.ร.บ.)
                      และภาคสมัครใจที่ยังให้ความคุ้มครอง</span
                    >
                  </li>
                  <li class="flex items-start">
                    <span class="mr-2 text-orange-500">•</span>
                    <span
                      >ยานพาหนะที่ใช้ต้องอยู่ในสภาพที่ปลอดภัยและได้รับการบำรุงรักษาอย่างสม่ำเสมอ</span
                    >
                  </li>
                  <li class="flex items-start">
                    <span class="mr-2 text-orange-500">•</span>
                    <span
                      >ต้องขับขี่อย่างปลอดภัย ปฏิบัติตามกฎจราจรอย่างเคร่งครัด
                      และไม่ใช้สารเสพติดหรือดื่มแอลกอฮอล์ก่อนหรือขณะขับขี่</span
                    >
                  </li>
                  <li class="flex items-start">
                    <span class="mr-2 text-orange-500">•</span>
                    <span
                      >ต้องให้ข้อมูลเส้นทาง, วัน-เวลาเดินทาง,
                      และจำนวนที่นั่งว่างที่ถูกต้องแก่ผู้โดยสาร</span
                    >
                  </li>
                  <li class="flex items-start">
                    <span class="mr-2 text-orange-500">•</span>
                    <span
                      >มีสิทธิ์ในการยอมรับหรือปฏิเสธคำขอร่วมเดินทางจากผู้โดยสาร</span
                    >
                  </li>
                </ul>
              </div>
            </div>
          </section>

          <!-- Section 6: การชำระเงิน -->
          <section
            id="section-6"
            class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card"
          >
            <h2 class="mb-4 text-2xl font-bold text-gray-900">
              ข้อ 6: การชำระเงิน
            </h2>
            <div
              class="p-6 border-l-4 rounded-r-lg bg-amber-50 border-amber-400"
            >
              <p class="text-gray-700">
                ค่าใช้จ่ายในการเดินทางเป็นการตกลงกันโดยตรงระหว่างผู้ขับขี่และผู้โดยสาร
                แพลตฟอร์ม "ไปนำแหน่"
                ไม่ได้มีส่วนเกี่ยวข้องในการทำธุรกรรมทางการเงินดังกล่าว
                และจะไม่รับผิดชอบต่อข้อพิพาทใดๆ ที่เกี่ยวกับการชำระเงิน
              </p>
            </div>
          </section>

          <!-- Section 7: ระบบการให้คะแนนและรีวิว -->
          <section
            id="section-7"
            class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card"
          >
            <h2 class="mb-4 text-2xl font-bold text-gray-900">
              ข้อ 7: ระบบการให้คะแนนและรีวิว
            </h2>
            <div
              class="p-6 border-l-4 border-indigo-400 rounded-r-lg bg-indigo-50"
            >
              <p class="mb-4 text-gray-700">
                แพลตฟอร์มสนับสนุนให้มีระบบการให้คะแนนและรีวิวเพื่อสร้างความน่าเชื่อถือในชุมชน
              </p>
              <div class="p-4 bg-white rounded-lg shadow-sm">
                <h3 class="mb-3 font-semibold text-indigo-900">
                  เงื่อนไขการรีวิว:
                </h3>
                <ul class="space-y-2 text-gray-700">
                  <li class="flex items-start">
                    <span class="mr-2 text-indigo-500">•</span>
                    <span>รีวิวต้องมาจากประสบการณ์จริงเท่านั้น</span>
                  </li>
                  <li class="flex items-start">
                    <span class="mr-2 text-indigo-500">•</span>
                    <span>ไม่ใช้ถ้อยคำหยาบคายหรือมีเนื้อหาที่ไม่เหมาะสม</span>
                  </li>
                  <li class="flex items-start">
                    <span class="mr-2 text-indigo-500">•</span>
                    <span>ไม่เป็นการหมิ่นประมาทหรือโจมตีส่วนบุคคล</span>
                  </li>
                </ul>
              </div>
              <div class="p-4 mt-4 rounded-lg bg-red-50">
                <p class="font-medium text-red-700">
                  ⚠️ แพลตฟอร์มขอสงวนสิทธิ์ในการลบรีวิวที่ไม่เป็นไปตามเงื่อนไข
                </p>
              </div>
            </div>
          </section>

          <!-- Section 8: ข้อจำกัดความรับผิด -->
          <section
            id="section-8"
            class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card"
          >
            <h2 class="mb-4 text-2xl font-bold text-gray-900">
              ข้อ 8: ข้อจำกัดความรับผิดของแพลตฟอร์ม
            </h2>
            <div class="p-6 border-l-4 border-red-400 rounded-r-lg bg-red-50">
              <div class="mb-4">
                <div class="flex items-center mb-2">
                  <svg
                    class="w-6 h-6 mr-2 text-red-600"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.5 0L4.268 15.5c-.77.833.192 2.5 1.732 2.5z"
                    />
                  </svg>
                  <h3 class="font-semibold text-red-900">
                    ข้อจำกัดความรับผิดชอบ
                  </h3>
                </div>
                <p class="mb-4 text-gray-700">
                  เนื่องจาก "ไปนำแหน่" เป็นเพียงตัวกลางในการเชื่อมต่อ
                  บริการของเราจึงมีให้ในลักษณะ "ตามที่เป็นอยู่" (As Is)
                </p>
              </div>
              <div class="p-4 bg-white rounded-lg shadow-sm">
                <h4 class="mb-3 font-semibold text-red-900">
                  เราขอปฏิเสธความรับผิดในเรื่องต่อไปนี้:
                </h4>
                <div class="grid grid-cols-1 gap-3 md:grid-cols-2">
                  <div class="flex items-center">
                    <span class="mr-2 text-red-500">×</span
                    ><span class="text-gray-700">ความเสียหายและการสูญเสีย</span>
                  </div>
                  <div class="flex items-center">
                    <span class="mr-2 text-red-500">×</span
                    ><span class="text-gray-700">การบาดเจ็บและอุบัติเหตุ</span>
                  </div>
                  <div class="flex items-center">
                    <span class="mr-2 text-red-500">×</span
                    ><span class="text-gray-700">ข้อพิพาทระหว่างผู้ใช้</span>
                  </div>
                  <div class="flex items-center">
                    <span class="mr-2 text-red-500">×</span
                    ><span class="text-gray-700">ความล่าช้าในการเดินทาง</span>
                  </div>
                </div>
                <p class="mt-3 text-sm text-gray-600">
                  * เหตุการณ์ใดๆ
                  ที่เกิดขึ้นจากการเดินทางซึ่งอยู่นอกเหนือการควบคุมของเรา
                </p>
              </div>
            </div>
          </section>

          <!-- Section 9: ทรัพย์สินทางปัญญา -->
          <section
            id="section-9"
            class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card"
          >
            <h2 class="mb-4 text-2xl font-bold text-gray-900">
              ข้อ 9: ทรัพย์สินทางปัญญา
            </h2>
            <div
              class="p-6 border-l-4 border-purple-400 rounded-r-lg bg-purple-50"
            >
              <div class="flex items-center mb-4">
                <svg
                  class="w-6 h-6 mr-2 text-purple-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"
                  />
                </svg>
                <h3 class="font-semibold text-purple-900">
                  ความเป็นเจ้าของทรัพย์สินทางปัญญา
                </h3>
              </div>
              <div class="p-4 bg-white rounded-lg shadow-sm">
                <p class="mb-4 text-gray-700">
                  ทรัพย์สินทางปัญญาทั้งหมดบนแพลตฟอร์ม "ไปนำแหน่"
                  ถือเป็นสิทธิ์ของแพลตฟอร์ม ประกอบด้วย:
                </p>
                <div class="grid grid-cols-2 gap-4 mb-4 md:grid-cols-4">
                  <div class="text-center">
                    <div
                      class="w-12 h-12 p-3 mx-auto mb-2 bg-purple-100 rounded-full"
                    >
                      <svg
                        class="w-6 h-6 text-purple-600"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M7 4V2a1 1 0 011-1h8a1 1 0 011 1v2M7 4h10l1 14H6L7 4z"
                        />
                      </svg>
                    </div>
                    <span class="text-sm text-gray-600">โลโก้</span>
                  </div>
                  <div class="text-center">
                    <div
                      class="w-12 h-12 p-3 mx-auto mb-2 bg-purple-100 rounded-full"
                    >
                      <svg
                        class="w-6 h-6 text-purple-600"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M4 5a1 1 0 011-1h14a1 1 0 011 1v2a1 1 0 01-1 1H5a1 1 0 01-1-1V5zM4 13a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H5a1 1 0 01-1-1v-6zM16 13a1 1 0 011-1h2a1 1 0 011 1v6a1 1 0 01-1 1h-2a1 1 0 01-1-1v-6z"
                        />
                      </svg>
                    </div>
                    <span class="text-sm text-gray-600">การออกแบบ</span>
                  </div>
                  <div class="text-center">
                    <div
                      class="w-12 h-12 p-3 mx-auto mb-2 bg-purple-100 rounded-full"
                    >
                      <svg
                        class="w-6 h-6 text-purple-600"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                        />
                      </svg>
                    </div>
                    <span class="text-sm text-gray-600">ข้อความ</span>
                  </div>
                  <div class="text-center">
                    <div
                      class="w-12 h-12 p-3 mx-auto mb-2 bg-purple-100 rounded-full"
                    >
                      <svg
                        class="w-6 h-6 text-purple-600"
                        fill="none"
                        stroke="currentColor"
                        viewBox="0 0 24 24"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          stroke-width="2"
                          d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"
                        />
                      </svg>
                    </div>
                    <span class="text-sm text-gray-600">ซอฟต์แวร์</span>
                  </div>
                </div>
              </div>
              <div class="p-4 mt-4 rounded-lg bg-red-50">
                <p class="font-medium text-red-700">
                  🚫 ห้ามมิให้มีการคัดลอก, ดัดแปลง,
                  หรือนำไปใช้โดยไม่ได้รับอนุญาตเป็นลายลักษณ์อักษร
                </p>
              </div>
            </div>
          </section>

          <!-- Section 10: การระงับและยกเลิกบัญชี -->
          <section
            id="section-10"
            class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card"
          >
            <h2 class="mb-4 text-2xl font-bold text-gray-900">
              ข้อ 10: การระงับ ยกเลิกบัญชี และระบบใบเหลือง–ใบแดง
            </h2>

            <div
              class="p-6 border-l-4 border-orange-500 rounded-r-lg bg-orange-50"
            >
              <div class="flex items-start">
                <!-- Icon -->
                <svg
                  class="w-8 h-8 mr-4 text-orange-600 shrink-0"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.5 0L4.268 15.5c-.77.833.192 2.5 1.732 2.5z"
                  />
                </svg>

                <div class="w-full">
                  <!-- สิทธิ์ในการดำเนินการ -->
                  <h3 class="mb-2 text-lg font-semibold text-orange-900">
                    สิทธิ์ในการดำเนินการทางวินัย
                  </h3>

                  <p class="mb-4 leading-relaxed text-gray-700">
                    "ไปนำแหน่" ขอสงวนสิทธิ์ในการตักเตือน ระงับ
                    หรือยกเลิกบัญชีผู้ใช้งานได้ทันที
                    หากพบว่ามีการกระทำที่ขัดต่อเงื่อนไขการใช้บริการ
                    หรือก่อให้เกิดความเสียหายต่อผู้อื่น ความปลอดภัยของระบบ
                    หรือชื่อเสียงของแพลตฟอร์ม
                  </p>

                  <!-- เหตุผล -->
                  <h4 class="mb-2 font-semibold text-orange-900">
                    เหตุผลในการระงับบัญชี
                  </h4>

                  <ul
                    class="mb-6 space-y-2 text-gray-700 list-disc list-inside"
                  >
                    <li>ละเมิดข้อตกลงและเงื่อนไขการใช้บริการ</li>
                    <li>มีพฤติกรรมที่เป็นอันตรายต่อผู้ใช้อื่น</li>
                    <li>สร้างความเสี่ยงทางกฎหมายให้กับแพลตฟอร์ม</li>
                    <li>ได้รับรายงานด้านความปลอดภัยในระดับร้ายแรง</li>
                  </ul>

                  <!-- ระบบใบเหลืองใบแดง -->
                  <div class="p-4 border border-orange-200 rounded-lg bg-white">
                    <h4 class="mb-3 font-semibold text-orange-900">
                      ระบบใบเหลือง–ใบแดง
                    </h4>

                    <ul class="space-y-2 text-gray-700 list-disc list-inside">
                      <li>
                        <strong>ใบเหลือง:</strong>
                        ใช้สำหรับการกระทำผิดที่ไม่ร้ายแรง
                        หรือเป็นการกระทำผิดครั้งแรก
                        โดยจะมีการบันทึกสะสมในบัญชีผู้ใช้งาน
                      </li>

                      <li>
                        <strong>เกณฑ์การสะสม:</strong>
                        หากผู้ใช้งานได้รับใบเหลืองครบ
                        <span class="font-semibold text-orange-700"
                          >3 ครั้ง</span
                        >
                        ระบบจะดำเนินการออก
                        <span class="font-semibold text-red-600"
                          >ใบแดงโดยอัตโนมัติ</span
                        >
                      </li>

                      <li>
                        <strong>ใบแดง (การแบน):</strong> เมื่อได้รับใบแดง
                        ผู้ใช้งานจะถูกระงับสิทธิ์การใช้งาน (Ban)
                        ตามระยะเวลาที่ผู้ดูแลระบบกำหนด
                        และอาจรวมถึงการระงับถาวรในกรณีร้ายแรง
                      </li>

                      <li>
                        การพิจารณาออกใบเหลืองหรือใบแดงจะอ้างอิงจากข้อมูลการรายงาน
                        หลักฐานที่แนบมา และดุลยพินิจของผู้ดูแลระบบ
                      </li>
                    </ul>

                    <p class="mt-4 text-sm text-gray-600">
                      หมายเหตุ: ประวัติใบเหลืองและใบแดงจะถูกบันทึกในระบบ
                      และอาจส่งผลต่อสิทธิ์การใช้งานในอนาคต
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </section>
          <!-- Section 11: การแก้ไขเปลี่ยนแปลงข้อตกลง -->
          <section
            id="section-11"
            class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card"
          >
            <h2 class="mb-4 text-2xl font-bold text-gray-900">
              ข้อ 11: การแก้ไขเปลี่ยนแปลงข้อตกลง
            </h2>
            <div class="p-6 border-l-4 border-teal-400 rounded-r-lg bg-teal-50">
              <div class="flex items-center mb-4">
                <svg
                  class="w-6 h-6 mr-2 text-teal-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"
                  />
                </svg>
                <h3 class="font-semibold text-teal-900">การอัปเดตข้อตกลง</h3>
              </div>
              <div class="space-y-4">
                <div class="p-4 bg-white rounded-lg shadow-sm">
                  <p class="mb-3 text-gray-700">
                    เราขอสงวนสิทธิ์ในการแก้ไขหรือเปลี่ยนแปลงข้อตกลงนี้ได้ทุกเมื่อ
                    การเปลี่ยนแปลงจะมีผลทันทีเมื่อมีการเผยแพร่บนแพลตฟอร์ม
                  </p>
                  <div class="flex items-center text-teal-700">
                    <svg
                      class="w-5 h-5 mr-2"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                      />
                    </svg>
                    <span class="font-medium"
                      >เราจะพยายามแจ้งให้ท่านทราบถึงการเปลี่ยนแปลงที่สำคัญ</span
                    >
                  </div>
                </div>
                <div class="p-4 rounded-lg bg-blue-50">
                  <p class="text-blue-700">
                    <strong>หมายเหตุ:</strong>
                    การที่ท่านยังคงใช้งานแพลตฟอร์มต่อไป
                    ถือว่าท่านยอมรับข้อตกลงฉบับใหม่
                  </p>
                </div>
              </div>
            </div>
          </section>

          <!-- Section 12: กฎหมายที่ใช้บังคับ -->
          <section
            id="section-12"
            class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card"
          >
            <h2 class="mb-4 text-2xl font-bold text-gray-900">
              ข้อ 12: กฎหมายที่ใช้บังคับ
            </h2>
            <div class="p-6 border-l-4 border-gray-400 rounded-r-lg bg-gray-50">
              <div class="flex items-center mb-4">
                <svg
                  class="w-6 h-6 mr-2 text-gray-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M3 6l3 1m0 0l-3 9a5.002 5.002 0 006.001 0M6 7l3 9M6 7l6-2m6 2l3-1m-3 1l-3 9a5.002 5.002 0 006.001 0M18 7l3 9m-3-9l-6-2m0-2v2m0 16V5m0 16H9m3 0h3"
                  />
                </svg>
                <h3 class="font-semibold text-gray-900">เขตอำนาจศาล</h3>
              </div>
              <div class="p-4 text-center bg-white rounded-lg shadow-sm">
                <div class="mb-3">
                  <svg
                    class="w-12 h-12 mx-auto text-red-500"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M3 21v-4m0 0V5a2 2 0 012-2h6.5l1 1H21l-3 6 3 6h-8.5l-1-1H5a2 2 0 00-2 2zm9-13.5V9"
                    />
                  </svg>
                </div>
                <p class="mb-2 text-lg font-semibold text-gray-900">
                  ข้อตกลงนี้อยู่ภายใต้การบังคับใช้และตีความตาม
                </p>
                <p class="text-2xl font-bold text-red-600">
                  กฎหมายแห่งราชอาณาจักรไทย
                </p>
              </div>
            </div>
          </section>

          <!-- Section 13: การติดต่อ -->
          <section
            id="section-13"
            class="p-8 mb-6 bg-white rounded-lg shadow-md content-section section-card"
          >
            <h2 class="mb-4 text-2xl font-bold text-gray-900">
              ข้อ 13: การติดต่อ
            </h2>
            <div
              class="p-6 border-l-4 border-green-400 rounded-r-lg bg-green-50"
            >
              <div class="flex items-center mb-4">
                <svg
                  class="w-6 h-6 mr-2 text-green-600"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
                  />
                </svg>
                <h3 class="font-semibold text-green-900">ติดต่อเรา</h3>
              </div>
              <div class="p-4 bg-white rounded-lg shadow-sm">
                <p class="mb-4 text-gray-700">
                  หากท่านมีคำถามเกี่ยวกับข้อตกลงและเงื่อนไขการใช้บริการนี้
                  กรุณาติดต่อเราผ่านทาง:
                </p>
                <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
                  <div class="flex items-center p-3 rounded-lg bg-gray-50">
                    <svg
                      class="w-5 h-5 mr-3 text-green-600"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2z"
                      />
                    </svg>
                    <div>
                      <div class="font-medium text-gray-900">อีเมล</div>
                      <div class="text-sm text-gray-600">
                        support@painahae.com
                      </div>
                    </div>
                  </div>
                  <div class="flex items-center p-3 rounded-lg bg-gray-50">
                    <svg
                      class="w-5 h-5 mr-3 text-green-600"
                      fill="none"
                      stroke="currentColor"
                      viewBox="0 0 24 24"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502ล4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"
                      />
                    </svg>
                    <div>
                      <div class="font-medium text-gray-900">โทรศัพท์</div>
                      <div class="text-sm text-gray-600">02-XXX-XXXX</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </section>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, onBeforeUnmount, ref } from "vue";
import { useHead } from "#imports";

// ตั้งค่า <head> สำหรับหน้า (โหลดฟอนต์ Kanit และตั้ง title)
useHead({
  title: "ข้อตกลงและเงื่อนไขการใช้บริการ - ไปนำแหน่",
  htmlAttrs: { lang: "th" },
  link: [
    { rel: "preconnect", href: "https://fonts.googleapis.com" },
    { rel: "preconnect", href: "https://fonts.gstatic.com", crossorigin: "" },
    {
      rel: "stylesheet",
      href: "https://fonts.googleapis.com/css2?family=Kanit:wght@300;400;500;600;700&display=swap",
    },
  ],
});

const scrollProgressEl = ref(null);

const onScroll = () => {
  // อัปเดตแถบความคืบหน้าขณะเลื่อน
  const doc = document.documentElement;
  const scrollTotal = doc.scrollHeight - doc.clientHeight;
  const scrolled = window.scrollY;
  const progress = scrollTotal > 0 ? (scrolled / scrollTotal) * 100 : 0;
  if (scrollProgressEl.value)
    scrollProgressEl.value.style.width = `${progress}%`;

  // อัปเดต active link ของสารบัญ
  const sections = Array.from(document.querySelectorAll(".content-section"));
  let current = "";
  sections.forEach((section) => {
    const top = section.offsetTop;
    if (window.scrollY >= top - 120) {
      current = section.getAttribute("id") || "";
    }
  });
  const links = Array.from(document.querySelectorAll(".toc-link"));
  links.forEach((a) => {
    a.classList.toggle("active", a.getAttribute("href") === `#${current}`);
  });
};

onMounted(() => {
  window.addEventListener("scroll", onScroll, { passive: true });
  // เรียกครั้งแรกให้สถานะถูกต้องตั้งแต่โหลดหน้า
  onScroll();
});

onBeforeUnmount(() => {
  window.removeEventListener("scroll", onScroll);
});
</script>

<style scoped>
.kanit-font {
  font-family:
    "Kanit",
    ui-sans-serif,
    system-ui,
    -apple-system,
    Segoe UI,
    Roboto,
    "Helvetica Neue",
    Arial,
    "Noto Sans",
    "Apple Color Emoji",
    "Segoe UI Emoji",
    "Segoe UI Symbol",
    "Noto Color Emoji",
    sans-serif;
}

.section-card {
  transition: all 0.3s ease;
}
.section-card:hover {
  transform: translateY(-1px);
  box-shadow: 0 6px 20px rgba(59, 130, 246, 0.1);
}

.highlight-box {
  background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%);
  border-left: 4px solid #3b82f6;
}

.scroll-indicator {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 4px;
  background: #e5e7eb;
  z-index: 1000;
}

.scroll-progress {
  height: 100%;
  background: linear-gradient(90deg, #3b82f6, #1d4ed8);
  width: 0%;
  transition: width 0.3s ease;
}

.content-section {
  scroll-margin-top: 100px;
}

.toc-link {
  transition: all 0.3s ease;
}
.toc-link:hover {
  background-color: #f3f4f6;
  padding-left: 1rem;
}
.toc-link.active {
  background-color: #eff6ff;
  border-left: 3px solid #3b82f6;
  padding-left: 1rem;
  color: #1d4ed8;
}
</style>
