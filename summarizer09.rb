#! ruby -Ks
#
# summarizer07.rb
# usage: ruby -Ks summarizer05.rb [-r 0.1~1.0] [-sen] < FILENAME.mcb.txt
# 2018.12.13 ���̒����𑪂�ǉ� ���ϒ����Z����� 1.2�{
require 'optparse' # �I�v�V�����̉��
options = Hash.new
OptionParser.new{|opt|
  opt.on('-sen'){|v| options[:sen] = v}
  opt.on('-r ritsu'){|v| options[:ritsu] = v}
  opt.parse!(ARGV)
}
if (options[:ritsu]) then
  ritsu = options[:ritsu].to_f
else
  ritsu=0.3 #--�f�t�H���g�̗v��
end
#-----------------------------------------------------------------
terms = 0  # ���P�ꐔ�𐔂��邽�߂̕ϐ��@�i 0�ŏ������j
tf=Hash.new  #tf�Ƃ������O�Ōʂ̒P�ꐔ�𐔂��邽�߂̃n�b�V���i�A�z�z��j����������
tf.default = 0 # �n�b�V�� tf �� �����l�� 0 �ɂ��Ă��� 
linect=0 # ���[�v2��ڗp�z��̓Y�����p ---------------------(�ǉ�)
hyoso = Array.new # �\�w�`��ۑ����邽�߂̔z�� -------------(�ǉ�)
kihon = Array.new # ��{�`��ۑ����邽�߂̔z�� -------------(�ǉ�)
hinshi= Array.new # �i����ۑ����邽�߂̔z��   -------------(�ǉ�)
sai1 = Array.new  # �i���̍ו���1��ۑ����邽�߂̔z��-------(�ǉ�)
sai2 = Array.new  # �i���̍ו���2��ۑ����邽�߂̔z��-------(�ǉ�)
sai3 = Array.new  # �i���̍ו���3��ۑ����邽�߂̔z��-------(�ǉ�)
#---------------------------------------------------------------------------
sc = 1 # ���ԍ�������ϐ� --------------------------------(�ǉ�)
sen = Array.new # ���{�̂�����ϐ�------------------------(�ǉ�)
sen[sc] = ""    # �ŏ��̕�����ɂ��ď����� -----------------(�ǉ�)
textlength=0 #---- text�̒���
while line=STDIN.gets # while���[�v�̊J�n �W�����͂���1�s�󂯎��line�ɑ��
  line.chomp! # �ϐ�line�ɂ��Ă�����s�R�[�h����������
  if line =="EOS" # line�̒��g�� 'EOS' ��������C�ȉ������s
    hyoso[linect]=line
    sc += 1 # ���ԍ���1���₷-----------------------------(�ǉ�)
    sen[sc] = "" # �V����������ɂ��ď�����-----------------(�ǉ�)
  else
    a = line.split(/\t/) # MeCab�̋�؂�q1 (line �� tab��split���āC�z��a�Ɍ��ʂ�ۑ�)
    b = a[1].split(/,/)  # MeCab�̋�؂�q2 (a[1] ��  , ��split���āC�z��b�Ɍ��ʂ�ۑ�)
    if b[6]=="*" # ��O
      b[6]=a[0]
    end
    tf[b[6]] +=1 # �n�b�V��tf�� b[6] �̕����ɒl1�𑫂��āC�㏑�� (b[6]����{�`)
    terms +=1  # �ϐ� terms �� 1�𑫂��āC�㏑��
    hyoso[linect]= a[0] # linect�Ԗڂ̕\�w�`��ۑ� ---------(�ǉ�)
    kihon[linect]= b[6] # linect�Ԗڂ̊�{�`��ۑ� ---------(�ǉ�)
    hinshi[linect]=b[0] # linect�Ԗڂ̕i����ۑ� -----------(�ǉ�)
    sai1[linect] = b[1] # linect�Ԗڂ̕i���̍ו���1��ۑ� --(�ǉ�)
    sai2[linect] = b[2] # linect�Ԗڂ̕i���̍ו���2��ۑ� --(�ǉ�)
    sai3[linect] = b[3] # linect�Ԗڂ̕i���̍ו���3��ۑ� --(�ǉ�)
    sen[sc] = sen[sc] + hyoso[linect] # --------------------(�ǉ�)

    textlength = textlength + 1 # �`�ԑf�P�ʂ̒���
    #textlength = textlength + hyoso[linect].size # �������P�ʂ̒���

  end #------- if�� �I���
  linect += 1 # ���[�v2��ڗp�̃J�E���g�ϐ���1�𑫂� -------(�ǉ�)
end #----- while���[�v�I���

avelength = textlength / (sc-1) # --- ���ϕ����̌v�Z
#
# types=0
# �n�b�V��tf����C1�v�f�����o���C�Y�����i�����̖�)��str�ɁC�l��str�ɑ��
#tf.each {|str, value|  
#  printf "%s\t%d\n", str, value # value�𐮐��Cstr�𕶎���Ƃ��ĕ\��
#  types+=1
#}
#printf "���P�ꐔ\t%d, �قȂ�P�ꐔ\t%d\n", terms, types # ���P�ꐔ�ƈقȂ�ꐔ��\��
sscr = Array.new # ���̓��_������z�� ------(summarizer02.rb�Œǉ�)
sc = 1 # ���ԍ� ------------------------------(summarizer02.rb�Œǉ�)
sscr[sc] = 0.0 # ���̓��_��0.0�ŏ����� ----------------(summarizer05.rb�ŏC��)
snum = Array.new  #���ԍ�������z�� -------------(summarizer03.rb�Œǉ�)
snum[sc] = sc # ���ԍ����L�^ ----------------------(summarizer03.rb�Œǉ�)

senlength = 0 # --- ���̒���

for i in 0..linect-1 # 0����n�߂Č`�ԑf�f�[�^�̏I���܂�
  if hyoso[i] == "EOS" # �\�w�� EOS�C1�����I���������
    # printf "SN: %d SCR: %d %s\n", sc, sscr[sc], sen[sc]

    if senlength > avelength   # ���̕��̒��������ϒ���蒷�����
      sscr[sc]=sscr[sc]*1.5    # ���X�R�A�� 1.2�{����
    end
    senlength = 0              # ���̕��̂��߂ɒ����� 0�ŏ�����

    sc += 1 # ���̕��ɐi�߂�
    sscr[sc] = 0 # ���̕��̓��_��0�ŏ�����
    snum[sc] = sc # ���ԍ����L�^ ------------------(summarizer03.rb�Œǉ�)
  else
    if hinshi[i] =~ /^����/ # ���̌�̕i����������������...
      sscr[sc] = sscr[sc] + tf[kihon[i]] # �\�w�`�̏o���p�x�𕶃X�R�A�ɑ���
    end

    senlength = senlength + 1             # �`�ԑf�P�ʂ̒���
    #senlength = senlength + hyoso[i].size # �����P�ʂ̒���

  end #------------- if hyoso[i] == "EOS" 
end #-----------------------------------�����܂� summarizer02.rb�Œǉ�-
#------------------------------ �X�R�A���Ƀ\�[�g summarizer03.rb�Œǉ�-
rank=Array.new # �e���̏��ʂ�����z��
for i in 1..sc-2
  for j in i+1..sc-1
    if sscr[i]<sscr[j]
      tmpscr = sscr[i]
      tmpnum = snum[i]
      sscr[i]= sscr[j]
      snum[i]= snum[j]
      sscr[j]= tmpscr
      snum[j]= tmpnum
    end
  end
  rank[snum[i]]=i # snum[i]�̕�������i�ʂł��邱�Ƃ��L�^����
end
rank[snum[sc-1]]=sc-1 # �Ō�̏��ʂ��L�^
#------------------ �v�񗦕��̏o�͕����̌v�Z�ƕ��בւ�--summarizer04.rb�Œǉ�- 
outnum=((sc-1)*ritsu).round # �o�͕��̐����v�Z����
for i in 1..outnum-1
  for j in i+1..outnum
    if snum[i]>snum[j]
      tmpsnum = snum[i]
      tmpsscr = sscr[i]
      snum[i] = snum[j]
      sscr[i] = sscr[j]
      snum[j] = tmpsnum
      sscr[j] = tmpsscr
    end
  end
end
#------------------ ���ʂ�\������ outnum���������o�� summarizer05.rb�ŏC��-
for i in 1..outnum
  if (options[:sen])
    printf "���� %2d �X�R�A %2f ���ԍ� %2d %s\n", 
          rank[snum[i]], sscr[i], snum[i], sen[snum[i]]
  else
    printf "���� %2d �X�R�A %2f ���ԍ� %d\n", 
          rank[snum[i]], sscr[i], snum[i]
  end
end
exit # �v���O�����I��
