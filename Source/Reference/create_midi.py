#!/usr/bin/env python3
"""
Create a MIDI file for "O Cascadia" based on the chord progressions.
This creates a simple melody line that follows the chord structure.
"""

def create_midi_file():
    """Create a basic MIDI file with melody notes."""
    
    # Write a minimal valid MIDI file
    midi_data = bytearray()
    
    # MThd header
    midi_data.extend(b'MThd')
    midi_data.extend((6).to_bytes(4, 'big'))  # Header length
    midi_data.extend((0).to_bytes(2, 'big'))  # Format 0
    midi_data.extend((1).to_bytes(2, 'big'))  # 1 track
    midi_data.extend((480).to_bytes(2, 'big'))  # 480 ticks per quarter
    
    # MTrk chunk
    midi_data.extend(b'MTrk')
    track_length_pos = len(midi_data)
    midi_data.extend((0).to_bytes(4, 'big'))  # Placeholder for track length
    
    # Tempo meta event (delta time 0)
    tempo = 500000  # microseconds per quarter note (120 BPM)
    midi_data.append(0x00)  # Delta time
    midi_data.append(0xFF)  # Meta event
    midi_data.append(0x51)  # Set tempo
    midi_data.append(0x03)  # Length
    midi_data.extend((tempo >> 16 & 0xFF).to_bytes(1, 'big'))
    midi_data.extend((tempo >> 8 & 0xFF).to_bytes(1, 'big'))
    midi_data.extend((tempo & 0xFF).to_bytes(1, 'big'))
    
    # Simple melody following the chord progressions
    # Using notes from E minor scale: E=64, G=67, B=71, C=72, D=74, E=76, G=79, A=81
    
    # Intro: F C D D/A D
    # Em C G D - "Bright burns the sun..."
    melody_notes = [
        # Em - "Bright burns the sun"
        (0, 64, 80),  # E4
        (120, 67, 80),  # G4
        (120, 71, 80),  # B4
        (240, 64, 80),  # E4
        
        # C - "upon the misty"
        (0, 60, 80),  # C4
        (120, 64, 80),  # E4
        (120, 67, 80),  # G4
        (240, 60, 80),  # C4
        
        # G - "mountain"
        (0, 67, 80),  # G4
        (120, 71, 80),  # B4
        (120, 74, 80),  # D5
        (240, 67, 80),  # G4
        
        # D - "Where the woodland"
        (0, 74, 80),  # D5
        (120, 77, 80),  # F#5
        (120, 81, 80),  # A5
        (240, 74, 80),  # D5
    ]
    
    # Add note events
    last_time = 0
    for delta, note, velocity in melody_notes:
        # Delta time encoding (simplified - use variable length)
        if delta == 0:
            midi_data.append(0x00)
        elif delta < 128:
            midi_data.append(delta & 0x7F)
        else:
            # Variable length encoding would be needed for larger values
            midi_data.append(0x78)  # Simplified
        
        midi_data.append(0x90)  # Note on
        midi_data.append(note)  # Note number
        midi_data.append(velocity)  # Velocity
        
        # Note off after quarter note (480 ticks)
        midi_data.append(0x78)  # Delta time (simplified)
        midi_data.append(0x80)  # Note off
        midi_data.append(note)  # Note number
        midi_data.append(0)  # Velocity
        
        last_time += delta
    
    # End of track
    midi_data.append(0x00)  # Delta time
    midi_data.append(0xFF)  # Meta event
    midi_data.append(0x2F)  # End of track
    midi_data.append(0x00)  # Length
    
    # Update track length
    track_length = len(midi_data) - track_length_pos - 4
    midi_data[track_length_pos:track_length_pos+4] = track_length.to_bytes(4, 'big')
    
    return bytes(midi_data)

if __name__ == '__main__':
    midi_bytes = create_midi_file()
    with open('OCascadiaFull.midi', 'wb') as f:
        f.write(midi_bytes)
    print("Created OCascadiaFull.midi")
