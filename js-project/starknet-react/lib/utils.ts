import {Buffer} from 'buffer'

export function feltToString(felt: any) {
    const newStrB = Buffer.from(felt.toString(16), 'hex')
    return newStrB.toString()
}
  
export function stringToFelt(str: string) {
    return "0x" + Buffer.from(str).toString('hex')
}
  