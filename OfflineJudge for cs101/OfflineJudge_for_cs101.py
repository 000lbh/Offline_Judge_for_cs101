
import subprocess
import os
import sys
import glob

if len(sys.argv)>1:
    testfile=os.path.abspath(sys.argv[1])
    finout=os.path.abspath(sys.argv[2])
    os.chdir(finout)
else:
    ftest=os.path.abspath(input('Input test file:'))
    fin=os.path.abspath(input('Input test data directory:'))
ftest=[testfile]
finout=finout+'\\' if finout[-1]!='\\' else finout
fin=glob.glob(finout+'*.in')
fout=glob.glob(finout+'*.out')
for k in ftest:
    print('Judging for',k)
    for i,j in zip(fin,fout):
        f=open(i,mode='r')
        inp=''.join(f.readlines())
        f.close()
        try:
            p=subprocess.Popen(['py',k],stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
            output,err=p.communicate(bytes(inp,encoding='utf-8'),timeout=1)
            out=output.decode('utf-8').splitlines()
        except subprocess.TimeoutExpired:
            p.kill()
            print('Time Limit Exceeded at',i+','+j,'!')
            break
        f=open(j,mode='r')
        out0=('\n'.join(f.readlines())).splitlines()
        f.close()
        while '' in out:
            out.remove('')
        while '' in out0:
            out0.remove('')
        if p.returncode!=0:
            print('Runtime error at',i+','+j)
            print('stderr:')
            print(err.decode('utf-8'))
            print('stdout:')
            print('\n'.join(out))
            print('Exitcode:%d'%(p.returncode))
            p.kill()
            break
        p.kill()
        errStatus=False
        if len(out)!=len(out0):
            errStatus=True
            errMessage='Wrong Answer:the number of the output lines does not match the answer\'s.'
        else:
            for l in range(len(out)):
                if out[l].strip()!=out0[l].strip():
                    errStatus=True
                    errMessage='Wrong Answer at '+i+','+j+'\nFound:\n'+out[l]+'\nExpected:\n'+out0[l]+'\nat Line '+str(l+1)+'.'
                    break
        if errStatus:
            print(errMessage)
            break
        else:
            print('   test',i,j,'OK!')
    else:
        print('Accept!')
input('Press Enter to continue. . .')
